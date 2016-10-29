*remove taint*


    kubectl taint nodes foo dedicated:NoSchedule-

    kubectl create -f https://gist.githubusercontent.com/davidwalter0/99d335ae6f44e465704d0717d0db6f61/raw/16dda706ebd56064824cdcb09485ad85a097b214/-

    journalctl -r -u kubelet

    vagrant ssh -- 'kubectl get po,rc,rs,ds,ep,svc --all-namespaces; kubectl get cs,ns,no; kubectl describe --namespace=kube-system po/$(kubectl get --namespace=kube-system pod|grep dns|tr "\t" " " | tr -s " "|cut -f 1 -d " ")'

    kubectl get po,rc,rs,ds,ep,svc --all-namespaces; kubectl get cs,ns,no; kubectl describe --namespace=kube-system po/$(kubectl get --namespace=kube-system pod|grep dns|tr "\t" " " | tr -s " "|cut -f 1 -d " ");

    for action in stop start status ; do systemctl ${action} -l kubelet ; done


    vagrant ssh -- kubectl run box --image busybox

    for action in stop start status ; do vagrant ssh -- systemctl ${action} -l kubelet ; done

    kubectl run box --image busybox

    for action in stop start status ; do sudo systemctl ${action} -l kubelet ; done
