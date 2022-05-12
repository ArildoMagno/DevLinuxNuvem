#!/usr/bin/awk -f
# organizador <destino> <origem> <arquivo-de-keywords> <opcao>

BEGIN{
    dest_folder = ARGV[1]; 
    source_folder = ARGV[2];
    keywords_file = ARGV[3];
    option = ARGV[4];
    current_class = "";
    
    delete ARGV[1]
    delete ARGV[2]
    delete ARGV[3]
    delete ARGV[4]


   # Cria a pasta destino caso ela nao existir
    if (!(isdir_destine(dest_folder))){
        createdir_destine(dest_folder)
    }

   start()
   end_keywords()
   end_namefiles()
}

# Verificacoes da existencia dos diretorios
function isdir_destine(dir) { 
    return !system("test -d \""dir"\"");
}


# Criacao dos diretorios
function createdir(dir) {
    dir_final = dest_folder "/" dir
    return system("mkdir -p \""dir_final"\"")
}

function createdir_destine(dir) {    
    return system("mkdir -p \""dir"\"")
}


# Execucao
function start(){
    file="tempkeywords.txt"
    keywords = system("cat " keywords_file " > " file)
    #Lendo as informações das Keywords
    count = 0
    while ((getline<file) > 0) {
        line = $0
        if (length(line) > 3){
            keywords_store[count] = line
            count = count + 1
        }
        
     }

     # Algoritmo baseado em construir o resultando iterativamente
     for(keyword in keywords_store) {
        
        line = keywords_store[keyword]

        # Classe
        if  (line ~ /[[A-Za-z\s]+]/){
            #remove []
            gsub(/[\[\]]+/, "", line)
            gsub(/ /, "", line)

           
           #cria o diretorio da classe na pasta destino
           createdir(line)
           current_class = line
        }
        # Keyword
        else{
            if (length(line) > 3){ 
                search_keyword(line)
           }
 
        }
       
     }
   
}



#busca na pasta origem a keyword
function search_keyword(keyword){
    # Usa o find para encontrar os arquivos
    file_search="tempfilenames.txt"
    system("find " source_folder " -type f > " file_search)
    gsub(/ /, "", keyword)

    #Obtem o nome dos arquivos da pasta origem
    count = 0
    while ((getline<file_search) > 0) {
        
        line_ = $0
        if (length(line_) > 3){
            file_store[count] = line_
            count = count + 1
        }
        
     }
    file_path_all_search="tempfilenamespathall.txt"
    for (file in file_store){
        comando = "readlink -f " file_store[file] " | tee -a tempfilenamespathall.txt"
        system(comando)
    }
   

    
      while ((getline<file_path_all_search) > 0) {
        line_ = $0
        if (length(line_) > 3){
            file_store_all[count] = line_
            count = count + 1
        }
        
     }




    #Passa a lista com os arquivos e seus diretorios para o metodo desejado
    if (option == "nome"){
       search_option_name(keyword, file_store_all)
    }

    if (option == "conteudo"){
       search_option_content(keyword, file_store_all)
    }

    if (option == "tudo"){
        search_option_content(keyword, file_store_all)
       search_option_name(keyword, file_store_all)
    }
   
}


function search_option_content(keyword, file_store){

   for(files in file_store) {
        line_ = file_store[files]

        split(line_,lineinfos,"/")
        text_ = lineinfos[length(lineinfos)]

        split(text_,textinfos,".") 
        extension = textinfos[2]
        #Se for do tipo txt verifica o conteudo
        if (extension == "txt"){
            file_source = line_

            #utiliza o cat e o grep para verificar o conteudo dos arquivos
            comando = "cat " file_source " | grep " keyword
            founded = system(comando)
            if (founded == 0){
                create_symbolic_link(text_, keyword, file_source)
            }
            
        }
    }
       
}




function search_option_name(keyword, file_store){
     #Percorrendo o array
     for(files in file_store) {
        line_ = file_store[files]
        split(line_,lineinfos,"/")
        text_ = lineinfos[length(lineinfos)]
        file_source = line_
        if ( text_ ~ keyword ){ 
                #cria o link simbolico do arquivo onde encontrou a keyword na pasta destino
                create_symbolic_link(text_,"", file_source)
                
        }
       
     }

}


function verify_symbolic_link_exists(dir) { 
    comando = "test -h " dir
    return !system(comando);
}

function create_symbolic_link(file, keyword, source){
    
    split(file,fileinfos,".") 
    file_name = fileinfos[1] "-" keyword
    gsub(/ /, "", file_name)
    gsub(/ /, "", file)

    dir_final = dest_folder "/" current_class "/" file_name 
    dir_final_bakcup = dir_final
    dir_source = source
    count_dir = 1
    
    #Cria outro arquivo se ja existir um
    while (verify_symbolic_link_exists(dir_final)){
        count_dir = count_dir + 1
        dir_final = dir_final_bakcup  count_dir
    }

    #ln -s [caminho do arquivo/diretório de destino] [nome simbólico]
    comando = "ln -s " dir_source " " dir_final
    return system(comando)
}


function end_keywords(){
    file="tempkeywords.txt"
    system("rm " file)
}

function end_namefiles(){
    file="tempfilenames.txt"
    file_path_hall="tempfilenamespathall.txt"
    system("rm " file)
    system("rm " file_path_hall)
}
