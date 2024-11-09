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
    echo $USAGE
  exit 1
fi

# Параметры:
BASE_DIR="$1"

# Функция для проверки использования оперативной памяти
check_memory_usage (){
    local memory_usage=$(free | awk '/Mem/ {printf "%.0f", $3/$2 * 100.0}')
    while [ "$memory_usage" -ge 30 ]
    do
        echo "Использование памяти более чем на 30% ($memory_usage%). Ожидание 2 секунды..."
        sleep 2
        memory_usage=$(free | awk '/Mem/ {printf "%.0f", $3/$2 * 100.0}')
        echo "Текущая загрузка памяти: $memory_usage%"
    done
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
            # Проверка использования памяти
            check_memory_usage
            # Если файла gost.pdf нет, выполняем команду
            magick `ls -v "$dir"/*.gif` "$dir/gost.pdf"
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
