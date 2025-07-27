# Company and Team Profiles

This directory contains predefined setup profiles for specific companies, teams, and organizations.

## Structure

```
profiles/
├── companies/      # Company-specific profiles
│   ├── startup.yaml
│   ├── enterprise.yaml
│   └── agency.yaml
├── teams/          # Team-specific profiles
│   ├── platform-team.yaml
│   ├── mobile-team.yaml
│   └── data-team.yaml
└── custom/         # Your custom profiles
```

## Using Profiles

### Apply a Company Profile
```bash
./setup.sh --profile companies/startup
```

### Apply a Team Profile
```bash
./setup.sh --profile teams/platform-team
```

### Create Your Own Profile
1. Copy an existing profile as a template
2. Customize the configuration
3. Save in the `custom/` directory
4. Apply with: `./setup.sh --profile custom/my-profile`

## Profile Format

Profiles are YAML files that define:
- Required roles
- Specific tool versions
- Company-specific configurations
- Custom aliases and functions
- Environment variables
- Git configuration
- Security policies

## Sharing Profiles

Profiles can be shared across teams:
1. Export your current setup: `./setup.sh --export my-profile.json`
2. Convert to YAML profile format
3. Share via Git repository
4. Team members apply with: `./setup.sh --profile shared/team-profile`