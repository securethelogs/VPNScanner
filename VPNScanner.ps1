

$logo = @(""
"____   _____________________                                                   ",
"\   \ /   /\______   \      \   ______ ____ _____    ____   ____   ___________ ",
" \   Y   /  |     ___/   |   \ /  ___// ___\\__  \  /    \ /    \_/ __ \_  __ \",
"  \     /   |    |  /    |    \\___ \\  \___ / __ \|   |  \   |  \  ___/|  | \/",
"   \___/    |____|  \____|__  /____  >\___  >____  /___|  /___|  /\___  >__|   ",
"                            \/     \/     \/     \/     \/     \/     \/       ",
"",
"Creator: https://securethelogs.com / @securethelogs",
"")

    $destip = @() 
    $iprange = @(1..254)
    $portstoscan = @(20,21,22,23,25,50,51,53,80,110,119,135,136,137,138,139,143,161,162,389,443,445,636,1025,1443,3389,5985,5986,8080,10000)
    $waittime = 100

    $subnet = (Get-NetIPAddress -AddressFamily IPv4).IPAddress | Select-Object -First 1


while ($true){

$logo


Write-Output "Current IP: $subnet"
Write-Output ""
Write-Output "Please Select An Option:"
Write-Output ""

Write-Output "Option 1: Scan Current Subnet/24"
Write-Output "Option 2: Scan IP List From Txt File"
Write-Output "Option 3: Change Current IP"


Write-Output ""

$opt = Read-Host -Prompt "Option:"



if ($opt -eq "1"){

    
    $subnetrange = $subnet.Substring(0,$subnet.IndexOf('.') + 1 + $subnet.Substring($subnet.IndexOf('.') + 1).IndexOf('.') + 3)

    $isdot = $subnetrange.EndsWith('.')

    if ($isdot -like "False"){$subnetrange = $subnetrange + '.'}

    
    #populate DestIP with IPs

    foreach ($i in $iprange){


    $currentip = $subnetrange + $i

    $destip += $currentip

}

}
    

if ($opt -eq "2"){

     Write-Output ""

    # Get the Target/s
    Write-Output "If you don't have a list, you can use sites such as http://magic-cookie.co.uk/iplist.html to create one"
    Write-Output ""
    $vpnippool = Read-Host -Prompt "Location Of IP list"
    
    
    $Typeofscan = $vpnippool
  

    if ($Typeofscan -like "*txt") {
    
    $PulledIPs = Get-Content $Typeofscan
    
    foreach ($i in $PulledIPs) {

    # Fill destination array with all IPs
    
    $destip += $i
    
    } # for each

    }

    else {
    
    Write-Output "Please use PSpanner or RedRabbit for more functionality"
    
    }



}

if ($opt -eq "3"){

Write-Output ""
$subnet = Read-Host -Prompt "Enter Your IP:"

}

else{

#Do Nothing

}






# Let's start scanning.......


foreach ($cip in $destip){



$islive = test-connection $cip -Quiet -Count 1

if ($islive -eq "True"){

try{$dnstest = (Resolve-DnsName $cip -ErrorAction SilentlyContinue).NameHost}catch{ 

$dnstest = "Cannot Resolve DNS"

}

if ($dnstest -like "*.home") {

$dnstest = $dnstest -replace ".home",""

}

Write-Output ""
Write-Output "Host is Reachable: $cip  |   DNS: $dnstest"


 # ------- Scanning host ---------

    

    foreach ($p in $portstoscan){

    $TCPObject = new-Object system.Net.Sockets.TcpClient
    try{$result = $TCPObject.ConnectAsync($cip,$p).Wait($waittime)}catch{}

    if ($result -eq "True"){
    
    Write-Output "Port Open: $p"
    
    }

    } # p in port

   



}

} #i in cip




$cont = Read-Host -Prompt "Re-run script? (Y/N)"

if ($cont -eq "n"){exit}else{}
   

   }