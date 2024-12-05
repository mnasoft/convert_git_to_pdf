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

# Проверка, что передан аргумент DIRECTORY
if [ -z "$1" ]; then
  echo "Использование: $0 <DIRECTORY>"
  exit 1
fi

# Основной каталог
BASE_DIR="$1"

# Функция для проверки PDF-файлов
check_pdfs() {
  local dir="$1"
  # Обход всех PDF-файлов в указанном каталоге
  for pdf in "$dir"/*.pdf; do
    # Проверка, существует ли файл
    if [ -f "$pdf" ]; then
      # Проверка PDF-файла с помощью qpdf --check
      # qpdf --check "$pdf" 2>/dev/null
        qpdf --check "$pdf" > /dev/null 2>&1
      # Если код возврата ненулевой, вывести относительное имя файла
      if [ $? -ne 0 ]; then
        echo "${pdf#$BASE_DIR/}"
      fi
    fi
  done
}

# Обход подкаталогов
find "$BASE_DIR" -type d | sort -V | while read -r subdir; do
  check_pdfs "$subdir"
done
