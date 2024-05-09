# Create the structure
#
#   /pvdata1/index.html
#     body: 1
#   /pvdata2/index.html
#     body: 2
#   /pvdata3/index.html
#     body: 3
#   /pvdata4/index.html
#     body: 4
#   /pvdata5/index.html
#     body: 5

HOST=$1

vagrant ssh $HOST -- "for i in {1..5}; do sudo mkdir -p \"/pvdata\$i\" && echo \"\$i\" | sudo tee \"/pvdata\$i/index.html\" > /dev/null; done"
