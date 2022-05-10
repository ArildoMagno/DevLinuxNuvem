#!/usr/bin/awk -f

BEGIN{
    source_folder = ARGV[1]; 
    delete ARGV[1]
    dest_folder =  ARGV[2];
    delete ARGV[2]

    if (!(isdir_destine(dest_folder))){
        createdir_destine(dest_folder)
    }

    start()
    end()
}

# Verificacoes da existencia dos diretorios
function isdir(dir) { 
    dir_final = dest_folder "/" dir 
    return !system("test -d \""dir_final"\"");
}

function isdir_destine(dir) { 
    return !system("test -d \""dir"\"");
}

# Criacao dos diretorios
function createdir(dir) {
    dir_final = dest_folder "/" dir
    return system("mkdir \""dir_final"\"")
}

function createdir_destine(dir) {    
    return system("mkdir \""dir"\"")
}

# Funcao move os arquivos
function movefile(file, file_extension){
    source_location = source_folder "/" file
    destine_location = dest_folder "/" file_extension "/" file
    return system("mv " source_location " " destine_location)
}

# Funcao cria a pasta de acordo com o tipo do arquivo ou ja move
function execute(file_name, file_extension){
    if (isdir(file_extension)) {
        movefile(file_name,file_extension)
    }
    else{
        createdir(file_extension)
        movefile(file_name,file_extension)
    }
}

# Execucao
function start(){
    file="tempfilenames.txt"
    system("ls " source_folder " > " file)

    while ((getline<file) > 0) {
        line = $0
        split(line,lineinfos,".") 
        
        file_name = line
        file_extension = lineinfos[2]
        execute(file_name,file_extension)
    }
   
}

function end(){
    file="tempfilenames.txt"
    system("rm " file)
}

