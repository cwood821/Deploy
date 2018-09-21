# Deploy

Drop-in `rsync` based deployment for small projects.

# Assumptions
- You have passwordless SSH configured for your server

# Usage 
- Add your SSH, server, and project information to the provided `.env` file
- Make the `deploy.sh` file executable
- Run `./deploy.sh` in your project's directory

# Bonus
Rsync output is logged to a directory you specify in the `.env` file.