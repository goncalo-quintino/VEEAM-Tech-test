
function Main {
    param (
        [Parameter(Position=0, Mandatory=$true)]
        [string]$source_path,
        [Parameter(Position=1, Mandatory=$true)]
        [string]$replica_path,
        [Parameter(Position=2, Mandatory=$true)]
        [string]$log_path
    )

    # Create log file
    $log_file_path = $log_path + "/" + "log.txt"
    if(!(Test-Path ($log_file_path))) {
        New-Item ($log_file_path)
    }
    Add-Content ($log_file_path) "Starting to sync `"$source_path`" to `"$replica_path`""

    Sync -source_path $source_path -replica_path $replica_path -log_file_path $log_file_path
}

# Sync is a recursive function and will call itself for every folder it encounters
function Sync {
    param (
        [string]$source_path, 
        [string]$replica_path, 
        [string]$log_file_path
    )

    # Get names of files and folders inside source and replica
    $source_list = Get-ChildItem $source_path -Name
    $replica_list = Get-ChildItem $replica_path -Name

    # Delete files or folders present on the replica but not on the source
    foreach ($file_name in $replica_list) {
        $source_file = $source_path + "/" + $file_name
        $replica_file = $replica_path + "/" + $file_name

        if ((Test-Path $replica_file) -and ((Test-Path $source_file) -eq $false)) {
            "$replica_file deleted from replica"
            Add-Content ($log_file_path) "File or folder deleted"
            Remove-Item -Path ($replica_file) -Recurse
        }
    }


    foreach ($file_name in $source_list) {
        $source_file = $source_path + "/" + $file_name
        $replica_file = $replica_path + "/" + $file_name
        
        # Check if the object is a file
        if (Test-path -Path $source_file -pathtype leaf) {
            if(Test-Path $replica_file) {
                # Compare file hashes
                if((Get-FileHash $source_file).Hash -eq (Get-FileHash $replica_file).Hash) {
                    $source_file + " Files are equal"
                    Add-Content ($log_file_path) "File already exists"
                } else {
                    $source_file + " Files are different"
                    Copy-Item $source_file -Destination $replica_file -force
                    Add-Content ($log_file_path) "File altered"
                }
            } else {
                Copy-Item $source_file -Destination $replica_file -force
                "$source_file File copied"
                Add-Content ($log_file_path) "File copied"
            }
        }
        
        # Check if the object is a folder
        if (Test-path -Path $source_file -pathtype Container) {
            if((Test-Path $replica_file) -eq ($false)) {
                New-Item -Path $replica_file -ItemType Directory
                Add-Content ($log_file_path) "Folder created"
                "$source_file Folder created"
            }
            # Continue the recursion on the next folder
            Sync -source_path $source_file -replica_path $replica_file -log_file_path $log_file_path
        }
    }  
}

# Start the recursion
Sync -source_path $source_path -replica_path $replica_path -log_file_path $log_file_path
