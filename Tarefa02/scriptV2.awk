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
function isdir(dir) { 
    dir_final = dest_folder "/" dir 
    return !system("test -d \""dir_final"\"");
}

function isdir_destine(dir) { 
    return !system("test -d \""dir"\"");
}


# Criacao dos diretorios
function createdir(dir) {
    #cria como subpasta da pasta destino
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
    #Pela estrutura das keywords, só entrara no if da nova classe
    #quando terminar de percorrer as outras keywords
    #Percorre os elementos da keywords
    while ((getline<file) > 0) {
        
        line = $0
        # Classe
        if  (line ~ /[[A-Za-z\s]+]/){
            #remove []
            gsub(/[\[\]]+/, "", line)

           
           #cria o diretorio da classe na pasta destino
           createdir(line)
           current_class = line
           print("current class:", current_class)
        }
        # Keyword
        else{

            if (length(line) > 0){
                search_keyword(line)

                #BUSCA KEYWORDS NOS ARQUIVOS DESTINO E CRIA OS LINKS

            }
 
        }

    }

   
}



#busca na pasta origem
function search_keyword(keyword){
    file="tempfilenames.txt"
    file_aux="tempfilenamesaux.txt"
    system("ls " source_folder " > " file)
    system("ls " source_folder " > " file_aux)
    gsub(/ /, "", keyword)
    


    if (option == "nome"){
        search_option_name(keyword, file)
    }
    if (option == "conteudo"){
        search_option_content(keyword, file)
    }

    if (option == "tudo"){
        search_option_content(keyword, file)
        search_option_name(keyword, file_aux)
    }

}


function search_option_content(keyword, file){

    while ((getline<file) > 0) {
        line = $0
        split(line,lineinfos,".") 
        file_name = lineinfos[1]
        extension = lineinfos[2]

        #Se for do tipo txt verifica o conteudo
        if (extension == "txt"){
           file_with_source = source_folder "/" line

            while ((getline<file_with_source) > 0) {
                line_inside = $0
               

                if ( line_inside ~ keyword ){ 
                   create_symbolic_link(line)
                   break
                }


            }


        }
       

    }

}


function search_option_name(keyword, file){
    while ((getline<file) > 0) {
        line = $0

        #encontrou a keyword pelo atributo nome
        if ( line ~ keyword ){ 
            #cria o link simbolico do arquivo onde encontrou a keyword na pasta destino
            create_symbolic_link(line)
         }


    }


}

function verify_symbolic_link_exists(dir) { 
    comando = "test -h " dir
    return !system(comando);
}

function create_symbolic_link(file){
    #pegando so o nome do arquivo para gerar o link simbolico
    split(file,fileinfos,".") 
    file_name = fileinfos[1] "link"
    #remove espacos em branco
    gsub(/ /, "", file_name)
    gsub(/ /, "", file)

    dir_final = dest_folder "/" current_class "/" file_name 
    dir_final_bakcup = dir_final
    dir_source = source_folder "/" file
    count_dir = 1
    
    
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
    file_aux="tempfilenamesaux.txt"
    system("rm " file)
    system("rm " file_aux)
}

