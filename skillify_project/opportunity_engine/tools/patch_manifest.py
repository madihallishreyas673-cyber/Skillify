"""Patch the generated AndroidManifest.xml: app name, internet permission,
and permission to open https links (job pages, learning resources)."""
import re
import sys

path = sys.argv[1]
s = open(path, encoding="utf-8").read()

# App name shown under the icon
s = re.sub(r'android:label="[^"]*"', 'android:label="Skillify"', s, count=1)

# Internet permission
if "android.permission.INTERNET" not in s:
    s = s.replace(
        "<application",
        '<uses-permission android:name="android.permission.INTERNET"/>\n    <application',
        1,
    )

# Allow opening https links (Android 11+ package visibility)
intent = (
    '<intent>\n            <action android:name="android.intent.action.VIEW"/>\n'
    '            <data android:scheme="https"/>\n        </intent>\n    '
)
if 'android:scheme="https"' not in s:
    if "</queries>" in s:
        s = s.replace("</queries>", intent + "</queries>", 1)
    else:
        s = s.replace("<application", "<queries>\n        " + intent + "</queries>\n    <application", 1)

open(path, "w", encoding="utf-8").write(s)
print("Manifest patched:", path)
