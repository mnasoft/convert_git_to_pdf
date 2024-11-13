#!/bin/bash
USAGE="
NAME:
        $(basename $0) 


SYNOPSIS:
        $(basename $0) dir


DESCRIPTION:

        Этот скрипт предназначен для поиска подкаталогов в указанном
        основном каталоге - dir, содержащих файлы с расширением .gif,
        и создания файла gost.pdf в этих подкаталогах, если файл
        gost.pdf отсутствует.


PARAMETERS:

        dir - основной каталог, в котором будет производиться поиск подкаталогов.
"

# Проверка, что передан аргумент BASE_DIR
if [ -z "$1" ]; then
    echo -e "$USAGE"
#    printf "%s\n" "$multi_line_var"    

  exit 1
fi

# Параметры:
BASE_DIR="$1"

create_pdf () {
    local cdir=`pwd`
    local dir=$1
    cd ${dir}
    # Замер времени выполнения функции
    start_time=$(date +%s)

    # Подсчет количества файлов с расширением .gif
    count=$(find . -type f -name "*.gif" | wc -l)
    
    echo -n "Количество файлов с расширением .gif в каталоге ${dir}: ${count} : "

    for i in `find . -name "*.gif" | sort -V`
    do
        magick $i $i.pdf
    done
    qpdf --empty --pages *.gif.pdf -- gost.pdf
    rm *.gif.pdf
    cd ${cdir}
    
    end_time=$(date +%s)
    execution_time=$((end_time - start_time))
    echo  "выполнено за: $execution_time секунд."
}

# Функция для обработки подкаталогов
process_directory() {
    local dir="$1"

    # Проверка наличия файлов *.gif
    if ls "$dir"/*.gif 1> /dev/null 2>&1
    then
        # Проверка наличия файла gost.pdf
        if [ ! -f "$dir/gost.pdf" ]
        then
            # check_memory_usage
            # Если файла gost.pdf нет, выполняем команду
            create_pdf "$dir"
            echo "Создан файл gost.pdf в каталоге: $dir"
        else
            echo "Файл gost.pdf уже существует в каталоге: $dir"
        fi
    fi
}

# Обход подкаталогов
find "$BASE_DIR" -type d | sort -V | while read -r subdir
do
  process_directory "$subdir"
done
