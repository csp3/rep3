<# REP3 : reproduce de música, de la lista hola.txt #>
<# .\reproduce.ps1 #>

Clear-Host 
#
[int]$global:totalcan = 0; # indice desde 1 
[int]$pasar           = 0;
[int]$salir           = 0;
$global:volum         = 0.5;
$termino              = $false; 
[int]$numPista        = 0; # indice desde 0 - 
$temporal             = ".\hola.txt"; 
$pausa                = $true; 
$global:nombre        = ""; 
$global:arreglo       = @();  
$temporizador         = (get-date -date "00:00:00") 
[int]$seg             = 0;
$global:auxTempo      = 0; 
$global:directorio;
$global:tiempo;
$keyInfo; 
# 
function principal 
{  
    posicion 29 5 
    Write-Host "  REP3  " -BackgroundColor red -ForegroundColor White 
    # 
    Add-Type -AssemblyName presentationCore
    $mediaPlayer = New-Object system.windows.media.mediaplayer 
    #
    posicion 0 0 
    menu  
    # 
    abrirDirectorio $temporal 
    # mostrar al inicio, $totalcan = total canciones = 334 actualmente 
    mostrar $global:arreglo $pasar 
    #
    while ($true) 
    {
        do {
            do
            {   
                # temporizador 
                $actual = (get-date -format "HH:mm:ss:") # solo las horas 
                if ($global:auxTempo -ne $actual -and !$pausa) 
                {
                    posicion 23 15
                    $a = $temporizador.AddSeconds($seg++).ToString("HH:mm:ss") 
                    write-host "-" $a -ForegroundColor DarkGray 
                    $global:auxTempo = $actual 
                    if ($global:tiempo.ToString() -le $a) 
                    {
                        $pausa = $true 
                        posicion 0 14 
                        write-host "Acción     : " -nonewline -foregroundColor red  
                        write-host "TERMINADO                 " -foregroundcolor cyan 
                    }
                } 
                # ingreso de key 
                if ([Console]::KeyAvailable)
                {
                    $keyInfo = [Console]::ReadKey($true)
                    break
                }
                # 
            } while ($true)
            # insertar pista (i) 
            if ($keyInfo.Key -eq "I") 
            {
                limpiaLinea 11 
                reproduceCancion $global:arreglo $mediaPlayer $numPista 
                #
                $seg = 0;
                $global:auxTempo = 0; 
                #
                posicion  0 13 
                write-host ($numPista+1)">" $global:nombre -foregroundcolor yellow 
                # 
                $pausa   = $false 
                $termino = $false 
            }
            # arriba - escoger pista - indices menores 
            if ($keyInfo.key -eq "UpArrow") 
            {
                if(($numPista--) -le 1)
                {
                    $numPista = $global:totalcan - 1 
                }
                mostrar $global:arreglo $numPista  
            } 
            # abajo - escoger pista - indices mayores 
            if ($keyInfo.key -eq "DownArrow") 
            {
                if (($numPista++) -ge $global:totalcan - 1) 
                {
                    $numPista = 0
                }
		        mostrar $global:arreglo $numPista   
            } 
            # derecha - volumen
            if ($keyInfo.key -eq "RightArrow") 
            {
                if( ($global:volum += 0.05) -le 1 )
                { 
                    $mediaPlayer.volume = $global:volum 
                }
                else 
                {
                    $global:volum = 1
                }
            }
            # izquierda - voolumen 
            if ($keyInfo.key -eq "LeftArrow") 
            {
                if( ($global:volum -= 0.05) -ge 0 )
                { 
                    $mediaPlayer.volume = $global:volum  
                }
                else 
                {
                    $global:volum = 0
                }
            }
            # terminar e 
            if ($keyInfo.key -eq "E") 
            {
                $mediaPlayer.stop() 
                $mediaPlayer.close()
                posicion 0 14 
                write-host "Acción     : " -nonewline -foregroundColor red  
                write-host "TERMINADO                 " -foregroundcolor cyan 
                #
                $termino       = $true 
                $pausa         = $true 
                $seg = 0;
                $global:auxTempo = 0;
            }
            # pause p 
            if ($keyInfo.key -eq "P") 
            {
                $pausa = $true 
                $b = 0;
                $mediaPlayer.pause() 
                posicion 0 14 
                if(!$termino) 
                {
                    write-host "Acción     : " -nonewline -foregroundColor red 
                    write-host "PAUSADO                 " -foregroundcolor cyan  
                    $termino = $false
                    # $pausa   = $false 
                }
            }
            # play x 
            if ($keyInfo.key -eq "X") 
            {
                $pausa = $false 
                $mediaPlayer.play()
                posicion 0 14 
                if(!$termino)
                {    
                    write-host "Acción     : " -nonewline -foregroundColor red  
                    write-host "REPRODUCIENDO           " -foregroundcolor cyan  
                    $termino = $false 
                    # $pausa   = $false 
                }
            }
            # aleatorio 
            if($keyInfo.Key -eq "R")
            {
                $numPista   = (Get-Random -Minimum 1 -Maximum $global:totalcan) 
                # 
                $seg = 0;
                $global:auxTempo = 0; 
                #
                reproduceCancion $global:arreglo $mediaPlayer $numPista 
                posicion  0 13 
                write-host ($numPista+1)">" $global:nombre -foregroundcolor yellow 
                #
                $pausa   = $false 
                $termino = $false 
            }
            # abrir directorio  
            if($keyInfo.Key -eq "A")
            {
                abrirDirectorio $temporal  
                $mediaPlayer.stop() 
                posicion 0 0 
                menu
                mostrar $global:arreglo $pasar    
            }
            # salir s 
            if ($keyInfo.key -eq "S") 
            {
                $mediaPlayer.stop() 
                $mediaPlayer.Close()
                $salir = 1
                break 
            }
        } while ( !($keyInfo.key -eq "E") -and !($keyInfo.Key -eq "S") ) # letras e, s  
        # saliendo 
        if ($salir) 
        {
            clear-host 
            write-host "`n-- Ud ha salido de Rep3 --`n" -foregroundcolor blue 
            break 
        }
    }
}
<##>
function mostrar
{
    param (
        $global:arreglo, 
        $pasar
    )
    # 
    $color = "darkgray" 
    limpiaLinea 6
    posicion  0 6 
    # Write-Host (Get-Content -Path $temporal -TotalCount $global:totalcan )[ $pasar + 0 ]"" -ForegroundColor black -backgroundcolor yellow 
    Write-Host $global:arreglo[ $pasar + 0 ]"" -ForegroundColor black -backgroundcolor yellow 
    limpiaLinea 7
    posicion  0 7
    # Write-Host (Get-Content -Path $temporal -TotalCount $global:totalcan )[ $pasar + 1 ] -ForegroundColor $color 
    Write-Host $global:arreglo[ $pasar + 1 ] -ForegroundColor $color 
    limpiaLinea 8
    posicion  0 8
    # Write-Host (Get-Content -Path $temporal -TotalCount $global:totalcan )[ $pasar + 2 ] -ForegroundColor $color 
    Write-Host $global:arreglo[ $pasar + 2 ] -ForegroundColor $color 
    limpiaLinea 9
    posicion  0 9 
    # Write-Host (Get-Content -Path $temporal -TotalCount $global:totalcan )[ $pasar + 3 ] -ForegroundColor $color 
    Write-Host $global:arreglo[ $pasar + 3 ] -ForegroundColor $color 
    limpiaLinea 10 
    posicion  0 10 
    # Write-Host (Get-Content -Path $temporal -TotalCount $global:totalcan )[ $pasar + 4 ] -ForegroundColor $color 
    Write-Host $global:arreglo[ $pasar + 4 ] -ForegroundColor $color 
}
<##>
function posicion
{
    param(
        [int]$xx,
        [int]$yy
    )
    $Host.UI.RawUI.CursorPosition = @{ X = $xx; Y = $yy }
}
<##>
function limpiaLinea 
{
    param (
        [int]$yy 
    )  
    $pshost    = Get-Host 
    # $newsize   = $pshost.UI.RawUI.BufferSize 
    # $tamanio   = $newsize.width 
    $newsize   = $pshost.UI.RawUI.windowsize 
    $tamanio   = $newsize.width
    #
    for ($x = 0; $x -lt $tamanio - 0; $x+=40) 
    {
        posicion $x $yy 
        write-host "                                        "
    }
}
<#duracion cancion#>
<##>
function duracion 
{
    param(
        [string]$directorio,
        [string]$nombre  
    )
    $ruta      = $nombre.split("\")
    $cancion   = $ruta[$ruta.Length - 1] 
    $objShell  = New-Object -ComObject Shell.Application 
    $objFolder = $objShell.Namespace($directorio) 
    $objFile   = $objFolder.ParseName($cancion)  
    # 
    $global:tiempo = $objFolder.GetDetailsOf($objFile, 27) 
    write-host -nonewline "Duración   : " -foregroundcolor red   
    Write-Host $global:tiempo -ForegroundColor cyan   
}
<##>
function menu
{
    $color      = "darkred" 
    $colorletra = "red"
    write-host "╔════╦════╦════╦════╦═══════╦═══════╦═══════╦═══════╦═════╦═════╗" -ForegroundColor $color
    write-host "║"       -foregroundcolor $color -nonewline   
    write-host " ⥮  "   -foregroundcolor $colorletra -nonewline 
    write-host "║"       -foregroundcolor $color -nonewline
    write-host " ▷  "   -foregroundcolor $colorletra -nonewline
    write-host "║"       -foregroundcolor $color -nonewline
    write-host " ◼  "   -foregroundcolor $colorletra -nonewline
    write-host "║"       -foregroundcolor $color -nonewline
    write-host " ▶ "    -foregroundcolor $colorletra -nonewline
    write-host " ║"      -foregroundcolor $color -nonewline
    write-host " salir " -foregroundcolor $colorletra -nonewline
    write-host "║"       -foregroundcolor $color -nonewline
    write-host " salir " -foregroundcolor $colorletra -nonewline
    write-host "║"       -foregroundcolor $color -nonewline
    write-host " pista " -foregroundcolor $colorletra -nonewline
    write-host "║"       -foregroundcolor $color -nonewline
    write-host " pista " -foregroundcolor $colorletra -nonewline
    write-host "║"       -foregroundcolor $color -nonewline  
    write-host " vol "   -foregroundcolor $colorletra -nonewline
    write-host "║"       -foregroundcolor $color -nonewline 
    write-host " vol "   -foregroundcolor $colorletra -nonewline
    write-host "║"       -foregroundcolor $color  
    write-host "║    ║    ║    ║    ║ pista ║       ║   -   ║   +   ║  -  ║  +  ║" -ForegroundColor $color  
    write-host "║"       -foregroundcolor $color -nonewline
    write-host "(P) "    -foregroundcolor $colorletra -nonewline
    write-host "║"       -foregroundcolor $color -nonewline
    write-host "(X) "    -foregroundcolor $colorletra -nonewline
    write-host "║"       -foregroundcolor $color -nonewline
    write-host "(E) "    -foregroundcolor $colorletra -nonewline
    write-host "║"       -foregroundcolor $color -nonewline
    write-host "(I) "    -foregroundcolor $colorletra -nonewline
    write-host "║"       -foregroundcolor $color -nonewline
    write-host "  (0)  " -foregroundcolor $colorletra -nonewline
    write-host "║"       -foregroundcolor $color -nonewline
    write-host "  (s)  " -foregroundcolor $colorletra -nonewline
    write-host "║"       -foregroundcolor $color -nonewline
    write-host "  (↓)  " -foregroundcolor $colorletra -nonewline
    write-host "║"       -foregroundcolor $color -nonewline
    write-host "  (↑)  " -foregroundcolor $colorletra -nonewline
    write-host "║"       -foregroundcolor $color -nonewline
    write-host " (←) "   -foregroundcolor $colorletra -nonewline
    write-host "║"       -foregroundcolor $color -nonewline
    write-host " (→) "   -foregroundcolor $colorletra -nonewline 
    write-host "║"       -foregroundcolor $color 
    write-host "╚════╩════╩════╩════╩═══════╩═══════╩═══════╩═══════╩═════╩═════╝" -ForegroundColor $color 
}
<##>
function reproduceCancion {
    param (
        $temporal, 
        $mediaPlayer,
        $pista 
    )
    # $nom    = (Get-Content -Path $temporal -TotalCount $global:totalcan)[ $pista ]
    $nom    = $global:arreglo[$pista] 
    $can    = $nom.split(">") 
    $global:nombre = $can[1] 
    $mediaPlayer.stop() 
    $mediaPlayer.open($global:nombre) 
    $mediaPlayer.volume = $global:volum   
    $mediaPlayer.Play() 
    # 
    mostrar $global:arreglo $pista  
    #
    limpiaLinea 11 
    limpiaLinea 14 
    posicion  0 14 
    write-host "Acción     : " -nonewline -foregroundColor red 
    write-host "REPRODUCIENDO           " -foregroundcolor cyan 
    posicion 0 15 
    duracion $global:directorio $global:nombre 
}
<##>
function abrirDirectorio
{
    param (
        $temporal 
    )
    $global:arreglo.Clear() 
    $global:totalcan = 0
    $global:directorio = dialogDirectorio 
    #
    limpiaLinea 13 
    posicion  0 13   
    write-host "0> " -nonewline -foregroundcolor yellow  
    limpiaLinea 14 
    posicion  0 14   
    write-host "Acción     : " -nonewline -foregroundcolor red  
    limpiaLinea 15 
    posicion  0 15   
    write-host "Duración   : " -nonewline -foregroundcolor red  
    limpiaLinea 16 
    posicion  0 16   
    write-host "Directorio : " -nonewline -foregroundcolor red  
    #
    write-host $global:directorio -foregroundcolor cyan  
    # 
    if (Test-Path -path $temporal -PathType leaf)
    {
        Remove-Item $temporal 
    } 
    if (!(Test-Path -path $global:directorio -PathType Container))  
    { 
        write-host "`nNo existe directorio`n-- Ud ha salido de Rep3 --`n" -foregroundcolor blue 
        exit  
    }
    # crear archivo hola.txt 
    Get-ChildItem -literalpath $global:directorio | ForEach-Object { 
        if($_.Extension -eq ".mp3") 
        { 
            $global:totalcan++; 
            [string]$global:totalcan + ">" + $_.FullName >> $temporal 
            $global:arreglo = $global:arreglo + ([string]$global:totalcan + ">" + $_.FullName)  
        } 
    } 
    #
    if($global:totalcan -le 0) 
    {
        exit 
    }
}
<##>
function dialogDirectorio {
    [Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    [System.Windows.Forms.Application]::EnableVisualStyles()
    $browse = New-Object System.Windows.Forms.FolderBrowserDialog
    $browse.SelectedPath = "D:\musica"
    $browse.ShowNewFolderButton = $false
    $browse.Description = "Seleccione directorio"

    $loop = $true
    while($loop)
    {
        if ($browse.ShowDialog() -eq "OK")
        {
            $loop = $false
            #Insert your script here
        } else
        {
            $res = [System.Windows.Forms.MessageBox]::Show("You clicked Cancel. Would you like to try again or exit?", "Select a location", [System.Windows.Forms.MessageBoxButtons]::RetryCancel)
            if($res -eq "Cancel")
            {
                #Ends script
                return
            }
        }
    }
    $browse.SelectedPath
    return $browse.Dispose()
} 
<##>
<# ejecutando #>  
principal
