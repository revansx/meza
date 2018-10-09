#!/bin/sh
#
# Check for changes to Meza and public config repository, then deploy as needed
#
# Run this command without args:
#
#     sudo ./check-for-changes.sh
#
# Or in a passwordless sudoer's (e.g. root) crontab like:
#
#     22 * * * * /opt/meza/src/scripts/autodeployer/check-for-changes.sh >> /opt/data-meza/logs/autodeploy-`date "+\%Y-\%m-\%d"`.log 2>&1
#

# Don't allow errors
set -e

echo "Start meza auto-deployer"
echo $(date "+%Y-%m-%d %H:%M:%S")

# Path to this file's directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# must be root or sudoer
if [ "$(whoami)" != "root" ]; then
	echo "Try running this script with sudo: \"sudo bash unite-the-wikis.sh\""
	exit 1
fi

# Check if a deploy is happening.
#
# This will cause the script to exit if a deploy is currently underway, thus
# preventing two deploys from happening at once.
#
# FIXME: not implemented yet
# source "$DIR/check-deploy.sh"

# Gets info about public config
source /opt/.deploy-meza/config.sh

#
# FIXME: For now, don't touch secret config. At some point find a way to
#        configure it's repo and version.

# Make sure config.sh is up-to-date in case there has been a secret config
# change since the last deploy, which could impact local_config_repo var.
meza setbaseconfig "$m_environment"
source /opt/.deploy-meza/config.sh


if [ -z "$local_config_repo_repo" ]; then
	>&2 echo "Auto-deploy requires 'local_config_repo' set in secret or public config"
	exit 1;
fi

# Set Slack notify variables that are the same for all notifications
if [ ! -z "$autodeployer_slack_token"    ]; then    SLACK_TOKEN="$autodeployer_slack_token";    fi
if [ ! -z "$autodeployer_slack_username" ]; then SLACK_USERNAME="$autodeployer_slack_username"; fi
if [ ! -z "$autodeployer_slack_channel"  ]; then  SLACK_CHANNEL="$autodeployer_slack_channel";  fi
if [ ! -z "$autodeployer_slack_icon_url" ]; then SLACK_ICON_URL="$autodeployer_slack_icon_url"; fi

# If SLACK_TOKEN is set, send notification via slack. Else, use no-notify script
if [ ! -z "$SLACK_TOKEN" ]; then
	NOTIFY="$DIR/slack-notify.sh"
else
	NOTIFY="$DIR/no-notify.sh"
fi

GIT_FETCH="$DIR/git-fetch.sh"

# Set PUBLIC config version
#
# Could optionally set public config's repo in secret config, but since that is
# not done universally, not going to enforce it here. Just use whatever repo is
# currently being used as origin.
PUBLIC_CONFIG_DEST="/opt/conf-meza/public"
PUBLIC_CONFIG_REPO="$local_config_repo_repo"
PUBLIC_CONFIG_VERSION="$local_config_repo_version"
PUBLIC_CONFIG_CHANGE=$($GIT_FETCH "$PUBLIC_CONFIG_REPO" "$PUBLIC_CONFIG_DEST" "$PUBLIC_CONFIG_VERSION")

#
# Check if attempt to git-pull PUBLIC CONFIG failed
#
# FIXME: For some reason the jq command below was not working if it was within
#        the conditional, so it has to be out here, where it forces us to
#        temporarily allow errors.
set +e
echo "Did git fetch fail on public config?"
echo "$PUBLIC_CONFIG_CHANGE" | jq '.plays[0].tasks[0].hosts.localhost.failed' -e
if [ $? -eq 0 ]; then
	FAILED_MSG=$(echo "$PUBLIC_CONFIG_CHANGE" | jq .plays[0].tasks[0].hosts.localhost.msg -r)
	FULL_MSG="Updating public config failed with following message:\n  $FAILED_MSG"
	>&2 echo -e "$FULL_MSG"

	if [ ! -z "SLACK_TOKEN" ]; then
		SLACK_MESSAGE="$FULL_MSG"
		SLACK_COLOR="danger"
		source $NOTIFY
	fi
	exit 1;
fi

#
# Check if changes were made to PUBLIC CONFIG
#
echo "Were there changes to public config?"
echo "$PUBLIC_CONFIG_CHANGE" | jq '.plays[0].tasks[0].hosts.localhost.changed' -e
if [ $? -eq 0 ]; then
	PUBLIC_CONFIG_BEFORE_HASH=$(echo "$PUBLIC_CONFIG_CHANGE" | jq '.plays[0].tasks[0].hosts.localhost.before' -r)
	PUBLIC_CONFIG_AFTER_HASH=$(echo "$PUBLIC_CONFIG_CHANGE" | jq '.plays[0].tasks[0].hosts.localhost.after' -r)
	echo "Before hash: $PUBLIC_CONFIG_BEFORE_HASH"
	echo "After hash:  $PUBLIC_CONFIG_BEFORE_HASH"

	pushd "$PUBLIC_CONFIG_DEST"
	PUBLIC_CONFIG_DIFF=$(git diff "$PUBLIC_CONFIG_BEFORE_HASH" "$PUBLIC_CONFIG_AFTER_HASH" 2>&1)
	PUBLIC_CONFIG_COMMITS=$(git log --oneline "$PUBLIC_CONFIG_BEFORE_HASH...$PUBLIC_CONFIG_AFTER_HASH" 2>&1)
	pushd
else
	PUBLIC_CONFIG_DIFF=""
	PUBLIC_CONFIG_AFTER_HASH=""
fi

# Make sure config.sh is up-to-date after public config change above, since it
# impacts what version of
meza setbaseconfig "$m_environment"
source /opt/.deploy-meza/config.sh


# This could change based upon changes to public config, so only check for it at
# this point, not earlier.
if [ -z "$enforce_meza_version" ]; then
	>&2 echo "Auto-deploy requires 'enforce_meza_version' var set in public or secret config"
	exit 1;
fi

# Set MEZA version
MEZA_REPO="https://github.com/enterprisemediawiki/meza"
MEZA_DEST="/opt/meza"
MEZA_VERSION="$enforce_meza_version"
MEZA_CHANGE=$($GIT_FETCH "$MEZA_REPO" "$MEZA_DEST" "$MEZA_VERSION")

#
# Check if attempt to git-pull MEZA failed
#
echo "Did git fetch fail on Meza?"
echo "$MEZA_CHANGE" | jq '.plays[0].tasks[0].hosts.localhost.failed' -e
if [ $? -eq 0 ]; then
	FAILED_MSG=$(echo "$MEZA_CHANGE" | jq .plays[0].tasks[0].hosts.localhost.msg -r)
	FULL_MSG="Updating Meza failed with following message:\n  $FAILED_MSG"
	>&2 echo -e "$FULL_MSG"

	if [ ! -z "SLACK_TOKEN" ]; then
		SLACK_MESSAGE="$FULL_MSG"
		SLACK_COLOR="danger"
		source $NOTIFY
	fi
	exit 1;
fi

#
# Check if changes were made to MEZA
#
echo "Were there changes to Meza?"
echo "$MEZA_CHANGE" | jq '.plays[0].tasks[0].hosts.localhost.changed' -e
if [ $? -eq 0 ]; then
	MEZA_BEFORE_HASH=$(echo "$MEZA_CHANGE" | jq '.plays[0].tasks[0].hosts.localhost.before' -r)
	MEZA_AFTER_HASH=$(echo "$MEZA_CHANGE" | jq '.plays[0].tasks[0].hosts.localhost.after' -r)
	echo "Before hash: $MEZA_BEFORE_HASH"
	echo "After hash:  $MEZA_AFTER_HASH"

	pushd "$MEZA_DEST"
	MEZA_COMMITS=$(git log --oneline "$MEZA_BEFORE_HASH...$MEZA_AFTER_HASH" 2>&1)
	pushd

else
	MEZA_AFTER_HASH=""
fi
set -e # end FIXME from above.


#
# Neither Meza mor config changed? Exit.
#
if [ -z "$PUBLIC_CONFIG_AFTER_HASH$MEZA_AFTER_HASH" ]; then
	echo "Nothing to deploy"
	exit 0;
fi

#
# Notify if PUBLIC CONFIG changed
#
if [ ! -z "$PUBLIC_CONFIG_AFTER_HASH" ]; then

	MESSAGE=$(cat <<-END
		Public config changed versions:
		  FROM: \`$PUBLIC_CONFIG_BEFORE_HASH\`
		  TO:   \`$PUBLIC_CONFIG_AFTER_HASH\`

		Tracking version: \`$PUBLIC_CONFIG_VERSION\`

		Commits:
		$PUBLIC_CONFIG_COMMITS

		Diff:
		\`\`\`
		$PUBLIC_CONFIG_DIFF
		\`\`\`
END
)

	echo -e "$MESSAGE"

	if [ ! -z "SLACK_TOKEN" ]; then
		SLACK_MESSAGE="$MESSAGE"
		SLACK_COLOR="good"
		source $NOTIFY
	fi
fi

#
# Notify if MEZA changed
#
if [ ! -z "$MEZA_AFTER_HASH" ]; then

	MESSAGE=$(cat <<-END
		Meza application changed versions:
		  FROM: \`$MEZA_BEFORE_HASH\`
		  TO:   \`$MEZA_AFTER_HASH\`

		Tracking version: \`$MEZA_VERSION\`

		Commits:
		$MEZA_COMMITS
END
)

	echo -e "$MESSAGE"

	if [ ! -z "SLACK_TOKEN" ]; then
		SLACK_MESSAGE="$MESSAGE"
		SLACK_COLOR="good"
		source $NOTIFY
	fi
fi


#
# Do deploy
#
echo "Deploying"
# Allow overriding variables by only setting them if they're empty
if [ -z "$DEPLOY_TYPE"       ]; then DEPLOY_TYPE="Deploy";                            fi
if [ -z "$DEPLOY_ARGS"       ]; then DEPLOY_ARGS="";                                  fi
if [ -z "$DEPLOY_LOG_PREFIX" ]; then DEPLOY_LOG_PREFIX="deploy-after-config-change-"; fi
source "$DIR/do-deploy.sh"
echo "Done"
