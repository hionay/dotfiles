# Regenerates glance.yml from the widget READMEs in widgets/ (vendored from
# github.com/glanceapp/community-widgets, CC0): python3 build.py
# Prints the env vars the result needs; keep .env.example in sync with them.
import re, sys, textwrap
from pathlib import Path

here = Path(__file__).parent
cw = here / "widgets"

def block(name, n=0, subs=()):
    """n-th ```yaml/yml block from a community widget README, with string replacements."""
    blocks = re.findall(r"```ya?ml\n(.*?)```", (cw / f"{name}.md").read_text(), re.S)
    text = blocks[n]
    for a, b in subs:
        assert a in text, (name, a)
        text = text.replace(a, b)
    return text

def at(text, indent):
    return textwrap.indent(text.rstrip("\n"), " " * indent)

def template_only(text):
    """Body of the `template: |` scalar, still indented as in the README."""
    return text.split("  template: |\n", 1)[1]

# NAS_HOST is the name the browser uses (links, images; 1Password matches on it).
# NAS_IP is for glance's own calls to services outside synobridge (plex on host
# network, dockhand on the default bridge), since the container may not resolve
# the hostname.
H = "http://${NAS_HOST}"
HI = "http://${NAS_IP}"

# Same-network containers are called by name (synobridge DNS). Going out to the
# NAS LAN IP and back is slow on DSM and times out. NAS_HOST is only for what the
# browser opens (links, images), plus plex (host network) and dockhand (default bridge).
def svc(name, port, path=""):
    return f"http://{name}:{port}{path}"

dockhand = block("dockhand", subs=[("title-url: ${DOCKHAND_URL}", f"title-url: {H}:4000"), ("${DOCKHAND_URL}", f"{HI}:4000")])
scrutiny = block("scrutiny", subs=[("http://${SCRUTINY_URL}/api", f"{svc('scrutiny', 8080)}/api"), ("${SCRUTINY_URL}", "${NAS_HOST}:6090")])
radarr = block("radarr-stats", subs=[("${RADARR_URL}", svc("radarr", 7878)), ("  refresh-interval: 5s\n", "")])
sonarr = block("sonarr-stats", subs=[("${SONARR_URL}", svc("sonarr", 8989)), ("  refresh-interval: 5s\n", "")])
plex = block("plex-stats", subs=[("title: Plex Stats", "title: Plex Activity"), ("${PLEX_URL}", f"{HI}:32400"), ("  refresh-interval: 5s\n", "")])
qbit = block("qbittorrent-stats", subs=[("${QBITTORRENT_IP}", "qbittorrent:8090"), ("title: qBittorrent", "title: Downloads"), ('view: "detailed"', 'view: "basic"')])
prowlarr = block("prowlarr-indexers", subs=[
    ('"${PROWLARR_URL}"', f'"{H}:9696"'),
    ("${PROWLARR_API_URL}", svc("prowlarr", 9696)),
    ("${PROWLARR_KEY}", "${PROWLARR_API_KEY}"),
    ("${PROWLARR_COLLAPSE_AFTER}", "5"),
])
tautulli_sub = [("url: http://${TAUTULLI_IP}:${TAUTULLI_PORT}", f"url: {svc('tautulli', 8181)}"), ("${TAUTULLI_IP}", "${NAS_HOST}"), ("${TAUTULLI_PORT}", "8181"), ("${SERVER_ID}", "${PLEX_SERVER_ID}")]
tautulli_added = block("tautulli-stats", 0, tautulli_sub + [('size: "small"', 'size: "large"')])
# Music (albums, artists) has no branch upstream and renders as a broken image;
# fall back to the item's own art, title and parent (album -> artist).
tautulli_added, n = re.subn(
    r'(\{\{ \$sub = printf "%d" \(\$v\.Int "year"\) \}\}\n)( *)\{\{ end \}\}',
    lambda m: m[1] + m[2] + "{{ else }}\n"
        + m[2] + '  {{ $img = $v.String "thumb" }}\n'
        + m[2] + '  {{ $title = $v.String "title" }}\n'
        + m[2] + '  {{ $sub = $v.String "parent_title" }}\n'
        + m[2] + "{{ end }}",
    tautulli_added)
assert n == 2, n
tautulli_playing = block("tautulli-stats", 1, tautulli_sub)
tautulli_watched = block("tautulli-stats", 2, tautulli_sub + [
    ("  title: Recently Watched\n", '  title: Recently Watched\n  options:\n    size: "small"\n    collapse: 5\n'),
])
# Shows full hostnames, no asset image, and service targets as text since they
# are container names the browser can't open.
cloudflared = block("cloudflared-tunnels", subs=[
    ("title: Cloudflared Tunnels", "title: Cloudflare Tunnel"),
    ("${CLOUDFLARE_API_KEY}", "${CLOUDFLARE_API_TOKEN}"),
    ('    {{ $domain_name := ".example.com" }}  {{/* Set your domain name */}}\n', ""),
    (' | trimSuffix $domain_name', ""),
    ("""<div class="text-left">
                <img src="assets/img/link-down-right.png" style="width: auto; height: 20px; margin-left: 0px; margin-top: -4px;">
              </div>""", '<div class="text-left color-subdue">\u21b3</div>'),
    ("""<a href='{{ .String "service" | replaceAll "localhost" "192.168.0.150" }}' target="_blank" rel="noreferrer">{{ .String "service" }}</a>""",
     '<span class="color-subdue">{{ .String "service" }}</span>'),
])
arr_tpl = re.sub(r'(/api/v\d/mediacover" )\$apiBaseUrl', r"\1$url", template_only(block("arr-releases")))

# upcoming: next 30 days, soonest first. recent: grabbed in the last 14 days,
# newest first. missing: everything monitored but not downloaded, newest first.
ARR_TIMING = {
    "upcoming": "interval: 30\n    sort-time: asc",
    "recent": "interval: 14",
    "missing": "",
}

def arr(title, service, port, key, kind="upcoming"):
    assert arr_tpl.count("mediacover\" $url") >= 3
    return f"""- type: custom-api
  title: {title}
  title-url: {H}:{port}
  cache: 30m
  options:
    service: {service}
    type: {kind}
    size: medium
    collapse-after: 4{"" if not ARR_TIMING[kind] else chr(10) + "    " + ARR_TIMING[kind]}
    api-base-url: {svc(service, port)}
    url: {H}:{port}
    key: ${{{key}}}
  template: *arr-releases"""

def site(title, port, icon, internal=None, path="", extra=""):
    check = f"\n  check-url: {svc(*internal)}" if internal else ""
    return f"""- title: {title}
  url: {H}:{port}{path}{check}
  timeout: 10s
  icon: {icon}{extra}"""

media_sites = [
    site("Plex", 32400, "di:plex", ("${NAS_IP}", 32400, "/identity"), path="/web"),
    site("Tautulli", 8181, "di:tautulli", ("tautulli", 8181)),
    site("Trawl", 8191, "di:flaresolverr", ("trawl", 8191, "/health"), path="/dashboard"),
    site("Sonarr", 8989, "di:sonarr", ("sonarr", 8989, "/ping")),
    site("Radarr", 7878, "di:radarr", ("radarr", 7878, "/ping")),
    site("Lidarr", 8686, "di:lidarr", ("lidarr", 8686, "/ping")),
    site("Bazarr", 6767, "di:bazarr", ("bazarr", 6767)),
    site("Prowlarr", 9696, "di:prowlarr", ("prowlarr", 9696, "/ping")),
    site("Profilarr", 6868, "di:profilarr", ("profilarr", 6868)),
    site("Pulsarr", 3003, "di:pulsarr", ("pulsarr", 3003), extra="\n  alt-status-codes: [404]"),
    site("qBittorrent", 8090, "di:qbittorrent", ("qbittorrent", 8090)),
    site("Pinchflat", 8945, "si:youtube", ("pinchflat", 8945, "/healthcheck")),
]
infra_sites = [
    site("Dockhand", 4000, "si:docker", ("${NAS_IP}", 4000)),
    site("Scrutiny", 6090, "di:scrutiny", ("scrutiny", 8080)),
    site("Miniflux", 8071, "di:miniflux", ("miniflux", 8080, "/healthcheck")),
]
personal_sites = [
    site("Quit Vaping", 8787, "si:checkmarx", ("quit-vaping", 8787)).replace(f"{H}:8787", "https://quit-vaping.halil.io"),
    site("Quotes", 5383, "si:quora", ("quotes", 8080)).replace(f"{H}:5383", "https://quotes.halil.io"),
    # Matrix bot without a UI; its webhook endpoint answers GET with 405.
    """- title: RubyChan
  url: https://github.com/hionay/rubychan
  check-url: http://rubychan:8080/webhook
  timeout: 10s
  icon: si:matrix
  alt-status-codes: [405]""",
]
adguard_site = """- title: AdGuard Home
  url: http://adguardhome
  check-url: ${ADGUARD_URL}
  timeout: 10s
  icon: di:adguard-home"""
service_sites = sorted(media_sites + infra_sites + [adguard_site], key=str.lower)

miniflux = f"""- type: custom-api
  title: Unread
  title-url: {H}:8071
  cache: 10m
  url: {svc('miniflux', 8080)}/v1/entries?status=unread&order=published_at&direction=desc&limit=20
  headers:
    X-Auth-Token: ${{MINIFLUX_API_KEY}}
  template: |
    <ul class="list list-gap-10 collapsible-container" data-collapse-after="6">
      {{{{ range .JSON.Array "entries" }}}}
      <li>
        <a class="size-title-dynamic color-primary-if-not-visited" href="{{{{ .String "url" }}}}" target="_blank" rel="noreferrer">{{{{ .String "title" }}}}</a>
        <ul class="list-horizontal-text">
          <li>{{{{ .String "feed.title" }}}}</li>
          <li {{{{ .String "published_at" | parseTime "rfc3339" | toRelativeTime }}}}></li>
        </ul>
      </li>
      {{{{ else }}}}
      <li class="color-subdue">Inbox zero.</li>
      {{{{ end }}}}
    </ul>"""

out = f"""# Glance dashboard for hio-nas.
# Every env var referenced below must exist in glance's environment (see .env.example),
# glance refuses to start on a missing one.
#
# glance calls same-network containers by name; NAS_HOST is used for links
# and images opened in the browser.

server:
  port: 8080

theme:
  # Glance's default palette; the previous teal look is in the theme picker.
  presets:
    teal:
      background-color: 225 14 15
      primary-color: 157 47 65
      contrast-multiplier: 1.1

# Follow the OS light/dark setting. Glance only switches theme through its
# picker (POST /api/set-theme/<key>, remembered in a cookie), so do the same
# whenever the page's scheme doesn't match. A dark preset picked by hand (teal)
# is kept while the OS is dark.
document:
  head: |
    <script>
    (() => {{
      const light = matchMedia("(prefers-color-scheme: light)");
      const sync = async () => {{
        const want = light.matches ? "light" : "dark";
        const html = document.documentElement;
        if (html.dataset.scheme === want) return;
        const key = want === "light" ? "default-light" : "default";
        const res = await fetch(pageData.baseURL + "/api/set-theme/" + key, {{ method: "POST" }});
        if (!res.ok) return;
        document.getElementById("theme-style").textContent = await res.text();
        html.dataset.theme = key;
        html.dataset.scheme = want;
        pageData.theme = key;
      }};
      sync();
      light.addEventListener("change", sync);
    }})();
    </script>

# Shared by the three "Upcoming" widgets on the Media page.
x-arr-releases-template: &arr-releases |
{at(arr_tpl.rstrip(), 2)}

pages:
  - name: Home
    columns:
      - size: small
        widgets:
          - type: clock
            hour-format: 24h

          - type: weather
            location: ${{WEATHER_LOCATION}}
            units: metric
            hour-format: 24h

          - type: server-stats
            servers:
              - type: local
                name: hio-nas

          # Reachable through the adguard-shim macvlan task on the NAS.
          - type: dns-stats
            title: AdGuard DNS
            service: adguard
            url: ${{ADGUARD_URL}}
            username: ${{ADGUARD_USERNAME}}
            password: ${{ADGUARD_PASSWORD}}
            hide-graph: true
            hide-top-domains: true

{at(scrutiny, 10)}

      - size: full
        widgets:
          - type: monitor
            title: Personal Projects
            cache: 1m
            sites:
{at(chr(10).join(personal_sites), 14)}

          - type: monitor
            title: Server Services
            cache: 1m
            sites:
{at(chr(10).join(service_sites), 14)}

          # split-column deals widgets round-robin (left, right, left, ...), so
          # this order gives: left = Plex, right = downloads/containers/tunnel.
          - type: split-column
            widgets:
              # Library sections 1 and 2 are assumed to be Movies and TV Shows.
{at(plex, 14)}

              # Needs Tools > Options > Web UI > "Bypass authentication for clients
              # in whitelisted IP subnets" with 172.20.0.0/16 in qBittorrent.
{at(qbit, 14)}

{at(tautulli_playing, 14)}

{at(dockhand, 14)}

{at(tautulli_watched, 14)}

              # Needs a remotely managed tunnel (token based) and an API token with
              # Account > Cloudflare Tunnel > Read.
{at(cloudflared, 14)}

{at(miniflux, 10)}

  - name: Media
    columns:
      - size: small
        widgets:
{at(sonarr, 10)}

{at(radarr, 10)}

{at(prowlarr, 10)}

      - size: full
        widgets:
          - type: group
            widgets:
{at(arr("Upcoming TV", "sonarr", 8989, "SONARR_API_KEY"), 14)}
{at(arr("Upcoming Movies", "radarr", 7878, "RADARR_API_KEY"), 14)}
{at(arr("Upcoming Music", "lidarr", 8686, "LIDARR_API_KEY"), 14)}

          # Missing music is left out: Lidarr counts every unowned album of
          # every monitored artist, so that list is huge.
          - type: group
            widgets:
{at(arr("Grabbed TV", "sonarr", 8989, "SONARR_API_KEY", "recent"), 14)}
{at(arr("Grabbed Movies", "radarr", 7878, "RADARR_API_KEY", "recent"), 14)}
{at(arr("Grabbed Music", "lidarr", 8686, "LIDARR_API_KEY", "recent"), 14)}
{at(arr("Missing TV", "sonarr", 8989, "SONARR_API_KEY", "missing"), 14)}
{at(arr("Missing Movies", "radarr", 7878, "RADARR_API_KEY", "missing"), 14)}

{at(tautulli_added, 10)}
"""

# Keep the file pure ASCII so a re-encoding editor or upload can't corrupt it:
# Go escapes inside {{ }} string literals, HTML entities everywhere else.
def ascii_only(line):
    parts = re.split(r"({{.*?}})", line)
    return "".join(
        re.sub(r"[^\x00-\x7f]", (lambda m: f"\\u{ord(m[0]):04x}") if p.startswith("{{") else (lambda m: f"&#x{ord(m[0]):x};"), p)
        for p in parts
    )

out = "\n".join(map(ascii_only, out.split("\n")))
(here / "glance.yml").write_text(out)

env = sorted(set(re.findall(r"(?<!\\)\$\{([A-Z_]+)\}", out)))
print("\n".join(env))
