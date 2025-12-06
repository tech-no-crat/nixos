# Quick Access Snippets



### Networking

1. Enable Wake on LAN if it doesnt boot with it on.
`sudo iw phy phy0 wowlan enable magic-packet disconnect`

2. Verify change has been applied.
`iw phy phy0 wowlan show`
