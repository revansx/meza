<?php
/**
 * Create (or replace) a bot password that can only be used from this server.
 *
 * Installed by meza's mwclient role. Run it once per wiki, since bot passwords
 * are stored per wiki:
 *
 *   WIKI=<wiki_id> /opt/htdocs/mediawiki/maintenance/run \
 *     /opt/meza-venvs/mwclient/share/meza/createLocalBotPassword.php \
 *     --appid <app-id> --grants basic,editpage [--user Mezabot]
 *
 * The bot password's "Allowed IP ranges" are set to:
 *   - 127.0.0.1/32 and ::1/128
 *   - every address that this wiki's hostname (from $wgServer) resolves to,
 *     provided that address belongs to one of this server's network interfaces.
 *
 * Scripts on this server reach the wiki through its public hostname, and Linux
 * uses the destination address as the source when a host connects to one of
 * its own addresses. MediaWiki therefore sees the server's own address, not
 * 127.0.0.1. If the hostname resolves to an address this server does not own
 * (for example a NAT or external load balancer address), the script stops,
 * because the source address MediaWiki sees could then be shared with other
 * machines. Use --allow-ip to add addresses deliberately.
 *
 * If a bot password with the same app ID already exists for the user, it is
 * deleted and recreated with a new password, grants and restrictions.
 *
 * @file
 * @ingroup Maintenance
 */

use MediaWiki\Maintenance\Maintenance;
use MediaWiki\User\BotPassword;
use MediaWiki\WikiMap\WikiMap;
use Wikimedia\IPUtils;
use Wikimedia\Rdbms\IDBAccessObject;

class CreateLocalBotPassword extends Maintenance {

	public function __construct() {
		parent::__construct();
		$this->addDescription(
			'Create or replace a bot password restricted to this server\'s own addresses.'
		);
		$this->addOption( 'appid', 'App ID for the bot password (e.g. "nightly-report")', false, true );
		$this->addOption( 'grants', 'Comma-separated grants (see --showgrants)', false, true );
		$this->addOption( 'user', 'Account that owns the bot password (default: Mezabot)', false, true );
		$this->addOption( 'allow-ip',
			'Comma-separated extra IP addresses or CIDR ranges to allow. Use only if you ' .
			'understand that requests from these addresses will be able to use this bot password.',
			false, true );
		$this->addOption( 'showgrants', 'List the valid grant names and exit' );
	}

	public function execute() {
		$services = $this->getServiceContainer();
		$validGrants = $services->getGrantsInfo()->getValidGrants();

		if ( $this->hasOption( 'showgrants' ) ) {
			sort( $validGrants );
			$this->output( implode( "\n", $validGrants ) . "\n" );
			return;
		}

		$appId = trim( (string)$this->getOption( 'appid', '' ) );
		$grantsText = trim( (string)$this->getOption( 'grants', '' ) );
		if ( $appId === '' || $grantsText === '' ) {
			$this->fatalError( "Both --appid and --grants are required. Use --showgrants to list grants." );
		}
		$grants = array_values( array_filter( array_map( 'trim', explode( ',', $grantsText ) ) ) );
		$invalid = array_diff( $grants, $validGrants );
		if ( $invalid ) {
			$this->fatalError( 'Invalid grants: ' . implode( ', ', $invalid ) .
				"\nUse --showgrants to list valid grant names." );
		}

		$userName = (string)$this->getOption( 'user', 'Mezabot' );
		$user = $services->getUserIdentityLookup()->getUserIdentityByName( $userName );
		if ( !$user || !$user->isRegistered() ) {
			$this->fatalError( "User '$userName' does not exist on this wiki." );
		}

		$allowed = $this->getAllowedRanges();

		$restrictions = MWRestrictions::newFromArray( [ 'IPAddresses' => $allowed ] );
		if ( !$restrictions->validity->isGood() ) {
			$this->fatalError( 'Invalid IP restrictions: ' . implode( ', ', $allowed ) );
		}

		$existing = BotPassword::newFromUser( $user, $appId, IDBAccessObject::READ_LATEST );
		if ( $existing ) {
			if ( !$existing->delete() ) {
				$this->fatalError( "Could not replace the existing bot password '$appId'." );
			}
			$this->output( "Replaced existing bot password '$appId' for {$user->getName()}.\n" );
		}

		$bp = BotPassword::newUnsaved( [
			'user' => $user,
			'appId' => $appId,
			'grants' => $grants,
			'restrictions' => $restrictions,
		] );
		if ( $bp === null ) {
			$this->fatalError( 'Bot password creation failed (check the app ID).' );
		}

		$password = BotPassword::generatePassword( $this->getConfig() );
		$passwordObj = $services->getPasswordFactory()->newFromPlaintext( $password );
		$status = $bp->save( 'insert', $passwordObj );
		if ( !$status->isGood() ) {
			$this->fatalError( $status );
		}

		$this->output(
			"Created bot password on wiki " . ( getenv( 'WIKI' ) ?: WikiMap::getCurrentWikiId() ) . ".\n" .
			"  Login name: {$user->getName()}@{$appId}\n" .
			"  Password:   $password\n" .
			"  Grants:     " . implode( ', ', $grants ) . "\n" .
			"  Allowed IP: " . implode( ', ', $allowed ) . "\n" .
			"The password is shown only once. Store it somewhere only the script's user can read.\n"
		);
	}

	/**
	 * Build the list of allowed IP ranges.
	 *
	 * @return string[]
	 */
	private function getAllowedRanges(): array {
		$allowed = [ '127.0.0.1/32', '::1/128' ];

		$extra = trim( (string)$this->getOption( 'allow-ip', '' ) );
		$extraRanges = [];
		if ( $extra !== '' ) {
			foreach ( array_map( 'trim', explode( ',', $extra ) ) as $range ) {
				if ( !IPUtils::isIPAddress( $range ) ) {
					$this->fatalError( "--allow-ip: '$range' is not an IP address or CIDR range." );
				}
				$extraRanges[] = $range;
			}
		}

		$server = (string)$this->getConfig()->get( 'Server' );
		$host = parse_url( $server, PHP_URL_HOST );
		if ( !$host ) {
			$this->fatalError( "Could not determine the wiki's hostname from \$wgServer ('$server')." );
		}
		$host = trim( $host, '[]' );

		$resolved = $this->resolveHost( $host );
		if ( !$resolved ) {
			$this->fatalError( "Could not resolve '$host' to any IP address." );
		}

		$local = $this->getLocalAddresses();
		$notLocal = [];
		foreach ( $resolved as $ip ) {
			if ( in_array( $ip, $local, true ) ) {
				$allowed[] = IPUtils::isIPv6( $ip ) ? "$ip/128" : "$ip/32";
			} elseif ( !$this->isCoveredBy( $ip, $extraRanges ) ) {
				$notLocal[] = $ip;
			}
		}

		if ( $notLocal ) {
			$this->fatalError(
				"'$host' resolves to " . implode( ', ', $notLocal ) . ", which does not belong to " .
				"this server.\nThis usually means NAT or an external load balancer sits in front of " .
				"the wiki. Requests from this server's scripts would then reach MediaWiki from an " .
				"address that other machines may share, so a bot password limited to it would not " .
				"be limited to this server.\nIf you understand and accept that, re-run with " .
				"--allow-ip <address-or-range>. See /opt/meza/manual/MWCLIENT.md."
			);
		}

		return array_values( array_unique( array_merge( $allowed, $extraRanges ) ) );
	}

	/**
	 * @param string $host Hostname or IP literal
	 * @return string[] Sanitized IP addresses
	 */
	private function resolveHost( string $host ): array {
		if ( IPUtils::isIPAddress( $host ) ) {
			return [ IPUtils::sanitizeIP( $host ) ];
		}
		$ips = gethostbynamel( $host ) ?: [];
		$records = @dns_get_record( $host, DNS_AAAA ) ?: [];
		foreach ( $records as $record ) {
			if ( isset( $record['ipv6'] ) ) {
				$ips[] = $record['ipv6'];
			}
		}
		return array_values( array_unique( array_map( [ IPUtils::class, 'sanitizeIP' ], $ips ) ) );
	}

	/**
	 * @return string[] Sanitized unicast addresses on this server's interfaces
	 */
	private function getLocalAddresses(): array {
		$ips = [];
		foreach ( net_get_interfaces() ?: [] as $iface ) {
			foreach ( $iface['unicast'] ?? [] as $addr ) {
				if ( isset( $addr['address'] ) && IPUtils::isIPAddress( $addr['address'] ) ) {
					// Strip any IPv6 zone index (e.g. fe80::1%eth0)
					$ips[] = IPUtils::sanitizeIP( explode( '%', $addr['address'] )[0] );
				}
			}
		}
		return array_values( array_unique( $ips ) );
	}

	/**
	 * @param string $ip
	 * @param string[] $ranges
	 * @return bool
	 */
	private function isCoveredBy( string $ip, array $ranges ): bool {
		foreach ( $ranges as $range ) {
			if ( IPUtils::isInRange( $ip, $range ) ) {
				return true;
			}
		}
		return false;
	}
}

return CreateLocalBotPassword::class;
