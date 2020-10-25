import os
import httpclient
import strutils
import nre


proc usage(): void =
    echo "Usage: MACLookup [MAC ADDRESS]"
    echo "\nAccepted formats:"
    echo "\t- MACLookup FC:FB:FB:01:FA:21"
    echo "\t- MACLookup FC-FB-FB-01-FA-21"
    echo "\t- MACLookup FCFBFB01FA21"


proc download(): void =
    echo "Downloading.."

    let f = open("MAC_ADDRESS.txt", fmAppend)
    defer: f.close()

    for line in newHttpClient().getContent("http://standards-oui.ieee.org/oui.txt").splitLines:
        if "(base 16)" in line:
             f.writeLine(line[0 .. 6], line[21 .. line.high()])
    
    echo "Download finished!"


proc matchMAC(MAC: string): string =
    let f = open("MAC_ADDRESS.txt", fmRead)
    defer: f.close()
    
    for address in lines(f):
        if address[0 .. 5] == MAC:
            echo address[8 .. address.high()]
            break


proc main(): void =
    if paramCount() != 1:
        usage()
        return


    # Remove any dashes or colons, if present
    let MAC: string = paramStr(1).replace(":", "").replace("-","")

    # Check if input is MAC address
    if MAC.match(re"^([0-9A-Fa-f]{12})$").isNone():
        echo "Invalid MAC address format!\n"
        usage()
        return

    # Check if MAC_ADDRESS.txt needs to be downloaded
    if not fileExists("MAC_ADDRESS.txt"):
        echo "MAC_ADDRESS.txt not found, would you like to download it? [y/n]: "
        if readLine(stdin).toLower() == "n":
            return
        else:
            download()


    # Finally, match MAC address with vendor
    echo matchMAC(MAC[0 .. 5])


main()