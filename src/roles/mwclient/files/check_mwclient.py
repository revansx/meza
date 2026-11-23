"""Deploy-time check for meza's mwclient installation.

Run with the mwclient virtual environment's Python. Exit codes:
  0  OK
  2  installed mwclient version differs from the expected version
  3  certificate verification failed for the wiki's hostname
  4  mwclient reports the wiki's MediaWiki version as unsupported
  5  any other connection or API error
"""
import argparse
import sys

import mwclient
import requests
from mwclient import errors


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--expected-version', required=True)
    parser.add_argument('--host', help='wiki_app_fqdn; omit to skip connection checks')
    parser.add_argument('--ca-bundle', help='CA bundle used to verify the certificate')
    parser.add_argument('--wiki', action='append', default=[], help='wiki ID (repeatable)')
    args = parser.parse_args()

    if mwclient.__version__ != args.expected_version:
        print('mwclient {} is installed, but mwclient_version is {}'.format(
            mwclient.__version__, args.expected_version))
        return 2
    print('mwclient {} installed'.format(mwclient.__version__))

    if not args.host:
        return 0

    for wiki in args.wiki:
        url = 'https://{}/{}/'.format(args.host, wiki)
        try:
            site = mwclient.Site(
                args.host,
                path='/{}/'.format(wiki),
                scheme='https',
                connection_options={'verify': args.ca_bundle or True, 'timeout': 30},
                clients_useragent='meza-deploy-check',
                max_retries=2,
                retry_timeout=5,
            )
        except requests.exceptions.SSLError as e:
            print('{}: certificate verification failed: {}'.format(url, e))
            return 3
        except errors.MediaWikiVersionError as e:
            print('{}: unsupported MediaWiki version: {}'.format(url, e))
            return 4
        except Exception as e:  # noqa: BLE001 - report anything else verbatim
            print('{}: {}: {}'.format(url, type(e).__name__, e))
            return 5

        if site.initialized:
            print('{}: OK, MediaWiki {}'.format(
                url, '.'.join(str(part) for part in site.version)))
        else:
            print('{}: OK, reachable (wiki requires login to read)'.format(url))

    return 0


if __name__ == '__main__':
    sys.exit(main())
