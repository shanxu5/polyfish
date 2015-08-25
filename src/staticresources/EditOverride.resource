function redirect(RecId, rfr){
     if (top != self) {
         top.location.replace('/'+RecId+'/e?retURL=' + rfr + '&nooverride=1');
     }
    else {top.location.replace('/'+RecId+'/e?retURL=' + rfr + '&nooverride=1');}
}