# paperless-tsa
Post-consumption script for paperless-ngx, allowing to automatically timestamp uploaded documents against an RFC 3161 timestamping authority.

## How to setup

Setup is straightforward: just drop the `timestamp_document.sh` script somewhere the Paperless server can read it, make it executable, and define the `PAPERLESS_POST_CONSUME_SCRIPT` environment variable to the path for your new script. More details about post-consumption scripts in [the paperless-ngx docs](https://docs.paperless-ngx.com/advanced_usage/#post-consume-script).

Afterwards, for any new uploaded document, the original in the `originals` folder (eg. mydoc.pdf in `/usr/src/paperless/media/documents/originals` on Docker) will be accompanied by the associated timestamp response (eg. mydoc.pdf.tsr).

## Initial timestamping

The script `timestamp_all.sh` provides a basic wrapper to timestamp all existing files that were uploaded before installing the post-consumption script.
