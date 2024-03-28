#!/bin/bash
while read path; do
    user=$(echo "$path" | cut -d/ -f3)
    echo $user"," $(su - $user -c "php '$path' --version" | grep "Magento CLI")
done < <(find /home -maxdepth 5 -type f -name "magento")
