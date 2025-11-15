# SideStore VPN tool

[SideStore](https://github.com/SideStore/SideStore) usually requires a WireGuard tunnel or [StosVPN](https://github.com/SideStore/StosVPN), so traffic generated during app install/refresh process can be hijacked and processed by SideStore itself.

This tool provides an alternative to the aforementioned tools, and can allow SideStore to work across all iOS devices on your local network, without setting up WireGuard or StosVPN individually.

# How it works

When installing or refreshing apps, SideStore opens ports on local iOS device mimicing a computer running developer software. Then it instructs iOS to connect to a computer at `10.7.0.1`.

This tool creates a TUN device expecting packets to 10.7.0.1, swap the source/destination field of each packet, and send them so that they are forwarded back to the iOS device sending the request. This will get iOS talking with SideStore's fake computer, and allow apps to be installed/refreshed.

This is the same approach as used by StosVPN: <https://github.com/SideStore/StosVPN/blob/main/TunnelProv/PacketTunnelProvider.swift>

# How to use

You need to run this tool on a Linux computer that is in the same LAN. This tool will not work if there are stateful NAT layers between the iOS device and the computer, since when sending the packets back, this tool is effectively initiating connections back to the iOS device, which will be blocked by stateful NAT.

You will also need to enable IP forwarding on that Linux machine.

Install `cargo` on your Linux machine, clone this repo, and run:

```bash
cargo build --release
sudo target/release/sidestore-vpn
```

Or build and run the docker container:

```bash
docker build -t sidestore-vpn:latest .
docker run -d sidestore-vpn:latest .
```

A new TUN device will be created, and start handling traffic to `10.7.0.1`.

If you're not running this tool on your router, you need to create a static route in your router with the following configuration.

- Route: `10.7.0.1/32`
- Netmask (if asked): `255.255.255.255`
- Gateway: IP address of the computer running this tool.

If your router doesn't allow you to create a `/32` route, you can expand the route a bit, as long as it doesn't conflict with your other devices:

- Route: `10.7.0.0/24`
- Netmask (if asked): `255.255.255.0`
- Gateway: IP address of the computer running this tool.

Once configured, your iOS devices should be able to install/refresh apps without WireGuard or StosVPN.

# Credit

Thanks to [SideStore](github.com/SideStore/SideStore) for creating an app to easily install apps on iOS devices.

Thanks to [StosVPN](https://github.com/SideStore/StosVPN) for the approach in networking.

# License

Public domain.
