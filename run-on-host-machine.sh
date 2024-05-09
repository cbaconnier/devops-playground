path="$HOME/.kube"

if [ ! -d $path ]; then
	mkdir -p $path
fi

vagrant ssh kubmaster -- "sudo cat /etc/kubernetes/admin.conf" >~/.kube/config
