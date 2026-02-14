#!/bin/bash

users=(
    "villariaq:iloveseals"
    "richardsonbes6:sealsaresupercute"
    "starkuwcl:sealsaresilly"
    "yorktfam:ilovesillyseals"
)

for user_pass in "${users[@]}"; do
    username="${user_pass%%:*}"
    password="${user_pass##*:}"

    if ! id "$username" &>/dev/null; then
        echo -ne "Creating user: $username"
        sudo useradd -m -s /bin/bash "$username"
        echo "$username:$password" | sudo chpasswd
        echo -e "\033[2K\r$username created with password"
    else
        echo -ne "User $username already exists."
        echo "$username:$password" | sudo chpasswd
        echo -e "\033[2K\r$username password updated"
    fi
done

echo -e "\nAll default users created successfully."