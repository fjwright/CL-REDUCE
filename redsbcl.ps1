# Start SBCL REDUCE using PowerShell.
# Author: Francis J. Wright <https://sourceforge.net/u/fjwright>
# Time-stamp: <2026-04-05 12:22:47 franc>

switch ( $args ) { # case insensitive matching!
    '-h' { $_ = '--help' }
    '--help' {
        Write-Output 'Start SBCL REDUCE using PowerShell.'
        Write-Output 'Usage: redsbcl <options>'
        Write-Output 'Useful options:'
        Write-Output '  -h, --help                  Print this message and exit.'
        Write-Output '  --version                   Print SBCL version information and exit.'
        Write-Output '  --control-stack-size <MiB>  Size of reserved control stack; default 2.'
        Write-Output '  --dynamic-space-size <MiB>  Size of reserved dynamic space.'
        Write-Output '  --no-rcfile                 Inhibit REDUCE startup file.'
        exit 
    }
    '--no-rcfile' { $norcfile = ' --no-rcfile' }
    default { $newargs += " $_" }
}
$newargs += $norcfile

Invoke-Expression "sbcl --noinform --core $PSScriptRoot\fasl.sbcl\reduce.img $newargs"

# SBCL runtime options should all work but not SBCL toplevel options,
# which are replaced by REDUCE options.  These are currently only
# --no-rcfile, which must appear after any runtime options.
