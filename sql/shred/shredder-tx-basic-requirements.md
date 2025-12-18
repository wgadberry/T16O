now that we have all the components needed to push data, let's discuss the proper design of a py process that does the following:   

1. fire python script (shredder-tx-basic.py) that takes an address as a parameter, as well as optionally parameter of "before" and limit of 20 to get basic-transactions.
pull code from shredder.py where needed to perform this task.

Here's an example of a call with no before:

import requests
url = "https://pro-api.solscan.io/v2.0/account/transactions?address=J2UXqJ1HYRwjCviLEqkY9mhoEPJ5UnoHEnbeijCweREV&before=5vVUzLSmgCriAjDY4EKN3JW58WojQZ3GinGrshwbBftVnnKzTc1MAcMZD8AffbcjYsdPyXp8aEwm7W5PBn6f2rdF&limit=20"    
headers = {"token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjcmVhdGVkQXQiOjE3NTg0MzQzODI5MTEsImVtYWlsIjoid2dhZGJlcnJ5QGdtYWlsLmNvbSIsImFjdGlvbiI6InRva2VuLWFwaSIsImFwaVZlcnNpb24iOiJ2MiIsImlhdCI6MTc1ODQzNDM4Mn0.d_ZYyfZGaFdLfYXsuB_M2rT_Q6WkwpxVp0ZqNE_zUAk"}
response = requests.get(url, headers=headers)

Here's an example of a call with before:

import requests
url = "https://pro-api.solscan.io/v2.0/account/transactions?address=J2UXqJ1HYRwjCviLEqkY9mhoEPJ5UnoHEnbeijCweREV&before=2zWDs9sbwsMHpe2Duz5DbfN5A3HvkCiKypy3mM6SebCqBfs5xgtXpVurVz35gmx2Wmn94FWMiT1gRJkhU9piNUC8&limit=20"    
headers = {"token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjcmVhdGVkQXQiOjE3NTg0MzQzODI5MTEsImVtYWlsIjoid2dhZGJlcnJ5QGdtYWlsLmNvbSIsImFjdGlvbiI6InRva2VuLWFwaSIsImFwaVZlcnNpb24iOiJ2MiIsImlhdCI6MTc1ODQzNDM4Mn0.d_ZYyfZGaFdLfYXsuB_M2rT_Q6WkwpxVp0ZqNE_zUAk"}
response = requests.get(url, headers=headers)


2. using the response from call #1, parse the x number of responses and create the following records using the following paths

tx = $.data
tx_address = addresses parsed from payload
tx_signer = $.data.signer[*]
tx_instruction = $.data.parsed_instructions[*]
tx_program = $.data.program_ids[*]


3. after json is shredded, loop to next 20 transactions passing "before" attribute = last signature from previous call
