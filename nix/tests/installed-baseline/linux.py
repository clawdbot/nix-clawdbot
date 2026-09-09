import shlex

start_all()
machine.succeed("test ! -e /home/baseline/qualification")
machine.succeed("loginctl enable-linger baseline")
machine.succeed("systemctl start user@1000.service")
machine.wait_for_unit("user@1000.service")
machine.wait_until_succeeds("test -S /run/user/1000/bus")
command = (
    "XDG_RUNTIME_DIR=/run/user/1000 "
    "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus "
    "python3 /etc/installed-baseline/probe.py "
    "/home/baseline/qualification /etc/installed-baseline/activation "
    "/etc/installed-baseline/bundle /etc/installed-baseline/node/bin/node"
)
print(machine.succeed(f"cd / && su baseline -c {shlex.quote(command)}"), end="", flush=True)
