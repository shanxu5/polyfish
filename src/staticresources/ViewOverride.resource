function redirect(RecId){
     if (top != self) {
         top.location.replace('/'+RecId+'?nooverride=1');
     }
     else {top.location.replace('/'+RecId+'?nooverride=1');}
}