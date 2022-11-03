function Test-LevenshteinDistance {

    param( 
        [Parameter(Position=0,Mandatory=$True)]
        [string]$Source,
        [Parameter(Position=1,Mandatory=$True)]
        [string]$Target
    )

    $sourceLength = $Source.Length
    $targetLength = $Target.Length

    $grid = New-Object -TypeName 'int[,]' -ArgumentList  ($sourceLength + 1),($targetLength + 1)

    for ($i = 0; $i -le $sourceLength; $i++) {
       $grid[$i, 0] = $i
    }

    for ($i = 0; $i -le $targetLength; $i++) {
       $grid[0, $i] = $i
    }

    for($i = 1; $i -le $sourceLength; $i++) {
      for($j  = 1; $j -le $targetLength; $j++) {
         $cost = 1
         if($Target[$j - 1] -eq $Source[$i - 1]) {
            $cost = 0
         } 
         $grid[$i, $j] = [System.Math]::Min(([System.Math]::Min((($grid[($i - 1), $j]) + 1), (($grid[$i, ($j - 1)]) + 1))), (($grid[($i - 1), ($j - 1)]) + $cost))
      }
    } 
    return $grid[$sourceLength,$targetLength]
}

$rows = Import-Csv d:\test\test.csv
foreach ($row in $rows) {

$LevenshteinDistance = Test-LevenshteinDistance $row.recipientDomain $row.internalDomain

$result = if($LevenshteinDistance -lt 4) {ForEach-Object {
    [PSCustomObject]@{
         result = [string]$LevenshteinDistance
         internal_domain  = [string]$row.recipientDomain
         external_domain = [string]$row.internalDomain
         user = [string]$row.destinationUserName_s
         }} | Export-Csv -NoTypeInformation -Path D:\test\test2.csv -Delimiter "," -append} 
}

