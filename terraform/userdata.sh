#!/bin/bash
# =============================================================================
# userdata.sh — EC2 bootstrap script
# Installs Nginx and deploys the Capgemini Invent static website.
# Runs once on first boot as root.
# =============================================================================

exec > /var/log/userdata.log 2>&1   # Capture all output for debugging

echo "==> [$(date)] Starting EC2 bootstrap"
echo "SHELL=$SHELL, USER=$USER, PWD=$PWD"

# ── 0. Network diagnostics ──────────────────────────────────────────────────
echo ""
echo "==> Network diagnostics"
echo "DNS resolution test:"
nslookup archive.ubuntu.com 2>&1 | head -5 || echo "DNS lookup failed"
echo ""
echo "Network connectivity test:"
curl -s -m 5 https://archive.ubuntu.com/ubuntu/dists/ > /dev/null && echo "✓ Can reach Ubuntu mirrors" || echo "✗ Cannot reach Ubuntu mirrors"
echo ""

# ── 1. System update & Nginx install ─────────────────────────────────────────
echo "==> Updating system packages"
if apt-get update -y 2>&1; then
  echo "✓ apt-get update succeeded"
else
  echo "✗ apt-get update failed (will attempt install anyway)"
fi

echo ""
echo "==> Installing Nginx"
if apt-get install -y nginx 2>&1; then
  echo "✓ Nginx installed successfully"
else
  echo "✗ Nginx installation failed!"
  echo "ERROR: Cannot proceed without Nginx. Check security group egress rules."
  exit 1
fi

echo ""
echo "==> Enabling and starting Nginx"
systemctl enable nginx 2>&1 || echo "Warning: systemctl enable failed"
systemctl start nginx 2>&1 || echo "Warning: systemctl start failed"
systemctl status nginx || echo "ERROR: Nginx did not start"
sleep 2
curl -s http://localhost/ > /dev/null && echo "✓ Nginx is listening on localhost" || echo "✗ Nginx is not responding"

# ── 2. Website root ───────────────────────────────────────────────────────────
WEB_ROOT="/var/www/html"
echo "==> Clearing default Nginx page"
rm -f "${WEB_ROOT}/index.nginx-debian.html"

# ── 3. HTML ───────────────────────────────────────────────────────────────────
cat > "${WEB_ROOT}/index.html" << 'HTML_EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Capgemini Invent</title>
  <link rel="stylesheet" href="style.css" />
</head>
<body>
  <header>
    <div class="header-inner">
      <div class="logo">Capgemini Invent</div>
      <nav><span class="nav-badge">DevOps Demo</span></nav>
    </div>
  </header>

  <main>
    <section class="hero">
      <div class="card">
        <div class="icon">🚀</div>
        <h1>Hello, Welcome to Capgemini Invent</h1>
        <div class="meta">
          <div class="meta-item">
            <span class="meta-label">Version</span>
            <span class="meta-value" id="version">v1.0</span>
          </div>
          <div class="divider"></div>
          <div class="meta-item">
            <span class="meta-label">Environment</span>
            <span class="meta-value env-badge" id="environment">Dev</span>
          </div>
        </div>
        <p class="description">
          Deployed on AWS EC2 using Nginx, provisioned with Terraform,
          and delivered via a GitHub Actions CI/CD pipeline.
        </p>
        <div class="stack-badges">
          <span class="badge">Terraform</span>
          <span class="badge">GitHub Actions</span>
          <span class="badge">AWS EC2</span>
          <span class="badge">Nginx</span>
        </div>
      </div>
    </section>

    <section class="welcome-panel">
      <div class="panel-card">
        <h2>Welcome to Capgemini Invent</h2>
        <p>Our DevOps demo shows a dynamic, modern landing experience powered by infrastructure as code and automated deployment.</p>
      </div>
    </section>

    <section class="team-grid">
      <div class="team-card">
        <h3>Team Members</h3>
        <ul id="team-list"></ul>
      </div>
      <div class="team-card">
        <h3>DevOps Technologies</h3>
        <ul id="tech-list"></ul>
      </div>
    </section>

    <section class="info-grid">
      <div class="info-card">
        <div class="info-icon">🏗️</div>
        <h3>Infrastructure</h3>
        <p>VPC, Subnets, Security Groups, and EC2 provisioned with Terraform IaC.</p>
      </div>
      <div class="info-card">
        <div class="info-icon">⚙️</div>
        <h3>CI/CD Pipeline</h3>
        <p>Automated deployments via GitHub Actions with Terraform plan and apply.</p>
      </div>
      <div class="info-card">
        <div class="info-icon">🔒</div>
        <h3>Security</h3>
        <p>AWS OIDC authentication. No long-lived credentials stored in GitHub.</p>
      </div>
    </section>
  </main>

  <footer>
    <div class="footer-inner">
      <span>© 2025 Capgemini Invent &nbsp;|&nbsp; DevOps Demo Project</span>
      <span id="deploy-time"></span>
    </div>
  </footer>
  <script src="app.js"></script>
</body>
</html>
HTML_EOF

# ── 4. CSS ────────────────────────────────────────────────────────────────────
cat > "${WEB_ROOT}/style.css" << 'CSS_EOF'
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
:root{--blue:#0070ad;--blue-dark:#00497a;--blue-light:#e6f2fa;--green:#00a86b;--gray:#f4f6f8;--text:#1a1a2e;--muted:#6b7280;--white:#ffffff;--radius:12px;--shadow:0 8px 32px rgba(0,112,173,.12)}
body{font-family:'Segoe UI',system-ui,-apple-system,sans-serif;background:var(--gray);color:var(--text);min-height:100vh;display:flex;flex-direction:column}
header{background:linear-gradient(135deg,var(--blue-dark) 0%,var(--blue) 100%);color:var(--white);padding:0 2rem;height:64px;position:sticky;top:0;z-index:100;box-shadow:0 2px 12px rgba(0,0,0,.18)}
.header-inner{max-width:1100px;margin:0 auto;height:100%;display:flex;align-items:center;justify-content:space-between}
.logo{font-size:1.25rem;font-weight:700}
.nav-badge{background:rgba(255,255,255,.18);border:1px solid rgba(255,255,255,.35);padding:4px 14px;border-radius:20px;font-size:.8rem;font-weight:600}
main{flex:1;max-width:1100px;margin:0 auto;width:100%;padding:3rem 1.5rem 2rem}
.hero{display:flex;justify-content:center;margin-bottom:2.5rem}
.card{background:var(--white);border-radius:var(--radius);box-shadow:var(--shadow);padding:3rem 3.5rem;text-align:center;max-width:680px;width:100%;border:1px solid rgba(0,112,173,.08)}
.icon{font-size:3rem;margin-bottom:1rem}
.card h1{font-size:clamp(1.4rem,3vw,2rem);font-weight:700;color:var(--blue-dark);margin-bottom:1.75rem;line-height:1.3}
.meta{display:flex;align-items:center;justify-content:center;gap:2rem;margin-bottom:1.75rem;background:var(--blue-light);border-radius:8px;padding:1rem 2rem}
.meta-item{display:flex;flex-direction:column;align-items:center;gap:4px}
.meta-label{font-size:.72rem;font-weight:600;text-transform:uppercase;letter-spacing:.08em;color:var(--muted)}
.meta-value{font-size:1.1rem;font-weight:700;color:var(--blue-dark)}
.env-badge{background:var(--green);color:var(--white);padding:2px 14px;border-radius:20px;font-size:.9rem}
.divider{width:1px;height:36px;background:rgba(0,112,173,.2)}
.description{color:var(--muted);line-height:1.7;margin-bottom:1.5rem;font-size:.95rem}
.stack-badges{display:flex;flex-wrap:wrap;gap:.5rem;justify-content:center}
.badge{background:var(--blue-light);color:var(--blue-dark);border:1px solid rgba(0,112,173,.2);padding:4px 14px;border-radius:20px;font-size:.78rem;font-weight:600}
.info-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(260px,1fr));gap:1.25rem}
.info-card{background:var(--white);border-radius:var(--radius);padding:1.75rem;box-shadow:0 2px 12px rgba(0,0,0,.06);border:1px solid rgba(0,112,173,.06);transition:transform .2s,box-shadow .2s}
.info-card:hover{transform:translateY(-3px);box-shadow:var(--shadow)}
.info-icon{font-size:1.75rem;margin-bottom:.75rem}
.info-card h3{font-size:1rem;font-weight:700;color:var(--blue-dark);margin-bottom:.5rem}
.info-card p{font-size:.875rem;color:var(--muted);line-height:1.6}
.welcome-panel{margin:0 auto 2rem;max-width:1100px;padding:0 1.5rem}
.panel-card{background:var(--white);border-radius:var(--radius);box-shadow:var(--shadow);padding:2rem; border:1px solid rgba(0,112,173,.08);text-align:center}
.panel-card h2{font-size:clamp(1.4rem,2vw,1.75rem);color:var(--blue-dark);margin-bottom:0.75rem}
.panel-card p{color:var(--muted);line-height:1.75}
.team-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(300px,1fr));gap:1.25rem;margin-bottom:2rem}
.team-card{background:var(--white);border-radius:var(--radius);box-shadow:var(--shadow);padding:1.75rem;border:1px solid rgba(0,112,173,.08)}
.team-card h3{font-size:1rem;font-weight:700;color:var(--blue-dark);margin-bottom:1rem}
.team-card ul{list-style:none;padding:0;display:grid;gap:0.75rem}
.team-card li{background:var(--blue-light);border-radius:999px;padding:0.75rem 1rem;color:var(--blue-dark);font-size:0.95rem}
footer{background:var(--blue-dark);color:rgba(255,255,255,.7);padding:1rem 2rem;font-size:.8rem}
.footer-inner{max-width:1100px;margin:0 auto;display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:.5rem}
@media(max-width:600px){.card{padding:2rem 1.25rem}.meta{flex-direction:column;gap:.75rem}.divider{width:60%;height:1px}.footer-inner{flex-direction:column;text-align:center}}
CSS_EOF

# ── 5. JavaScript ─────────────────────────────────────────────────────────────
cat > "${WEB_ROOT}/app.js" << 'JS_EOF'
const deployTimeEl = document.getElementById("deploy-time");
if (deployTimeEl) {
  const now = new Date();
  deployTimeEl.textContent =
    "Deployed: " +
    now.toLocaleDateString("en-GB",{day:"2-digit",month:"short",year:"numeric"}) +
    " " +
    now.toLocaleTimeString("en-GB",{hour:"2-digit",minute:"2-digit"});
}

const teamMembers = [
  "Aisha Patel - Release Engineer",
  "Daniel Kim - Automation Specialist",
  "Priya Singh - Cloud Architect",
  "Marcus Lee - Platform Engineer",
  "Nina Gupta - Site Reliability Engineer"
];

const devopsTech = [
  "Terraform",
  "GitHub Actions",
  "AWS EC2",
  "Nginx",
  "IAM OIDC",
  "Ubuntu 22.04"
];

const teamList = document.getElementById("team-list");
const techList = document.getElementById("tech-list");

if (teamList) {
  teamMembers.forEach(member => {
    const li = document.createElement("li");
    li.textContent = member;
    teamList.appendChild(li);
  });
}

if (techList) {
  devopsTech.forEach(tool => {
    const li = document.createElement("li");
    li.textContent = tool;
    techList.appendChild(li);
  });
}

console.log("%cCapgemini Invent DevOps Demo","color:#0070ad;font-size:1.1rem;font-weight:bold;");
JS_EOF

# ── 6. Fix permissions & restart Nginx ───────────────────────────────────────
chown -R www-data:www-data "${WEB_ROOT}"
chmod -R 755 "${WEB_ROOT}"
systemctl restart nginx

echo "==> [$(date)] Bootstrap complete. Website live on port 80."
