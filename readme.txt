This is a solution to the VEEAM tech test for the position "PowerShell Developer in QA" by Goncalo Quintino - gonmtq@gmail.com

The program receives te following arguments from the command line:
- source_path: The path to the folder with the content that should be replicated
- replica_path: The path to the folder where the content should be replicated to
- log_path: The path where the log file will be created

The program takes the following steps:
- Looks for folders or files in replica that don't exist in source and deletes them
- Verifies what files need to be copied to the replica by comparing md5 hashes
- Finds all the folders inside the original folder and creates them in replica if necessary
- Repeats the operations above for all the folders inside the original folder using the recursive function "Sync"
- This function synchronizes all the folders inside the original folder regardless of its depth

To launch the program use the command:
pwsh Task_Goncalo_Quintino.ps1 -source_path (source path) -replica_path (replica path) -log_path (log path)

To launch the tests use:
pwsh run_tests.ps1
