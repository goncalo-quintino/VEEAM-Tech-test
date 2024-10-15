Import-module ./Task_Goncalo_Quintino.ps1 -Force

Describe "Verify it copies a file to the replica" {
    Context "When function Main runs" {
        It "File in the Replica matches the Source" {
            $file_name = "file.txt"
            $source_path = "./source"
            $replica_path = "./replica"
            $source_file = $source_path + "/" + $file_name
            $replica_file = $replica_path + "/" + $file_name

            New-Item -Path $source_path -ItemType Directory
            New-Item -Path $replica_path -ItemType Directory
            New-Item -Path $source_file -ItemType File

            (Test-Path $replica_file) | Should -Be $false
        
            Main -source_path $source_path -replica_path $replica_path -log_path $source_path

            (Test-Path ($source_path + "/log.txt")) | Should -Be $true

            (Test-Path $replica_file) | Should -Be $true
            ((Get-FileHash $source_file).Hash -eq (Get-FileHash $replica_file).Hash) | Should -Be $true

            # Test teardown
            Remove-Item -Path $source_path -Recurse
            Remove-Item -Path $replica_path -Recurse
        }
    }
}

Describe "Verify it copies a folder and its content to the replica" {
    Context "When function Main runs" {
        It "Folder exists in Replica" {
            $folder_name = "folder"
            $file_name = "file.txt"
            $source_path = "./source"
            $replica_path = "./replica"
            $source_folder = $source_path + "/" + $folder_name
            $replica_folder = $replica_path + "/" + $folder_name
            $source_file = $source_path + "/" + $folder_name + "/" + $file_name
            $replica_file = $replica_path + "/" + $folder_name + "/" + $file_name

            New-Item -Path $source_path -ItemType Directory
            New-Item -Path $replica_path -ItemType Directory
            New-Item -Path $source_folder -ItemType Directory
            New-Item -Path ($source_folder + "/" + $file_name) -ItemType File

            (Test-Path $replica_folder) | Should -Be $false
        
            Main -source_path $source_path -replica_path $replica_path -log_path $source_path

            (Test-Path ($source_path + "/log.txt")) | Should -Be $true

            (Test-Path $replica_folder) | Should -Be $true

            (Test-Path $replica_file) | Should -Be $true
            ((Get-FileHash $source_file).Hash -eq (Get-FileHash $replica_file).Hash) | Should -Be $true

            # Test teardown
            Remove-Item -Path $source_path -Recurse
            Remove-Item -Path $replica_path -Recurse
        }
    }
}
