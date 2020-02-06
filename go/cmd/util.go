package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/360EntSecGroup-Skylar/excelize"
	"github.com/nanitefactory/winmb"
)

//Парсинг timestamp->время
func str2Time(str string) time.Time {
	str = strings.ReplaceAll(str, " ", "")
	day, _ := strconv.Atoi(str[0:2])
	month, _ := strconv.Atoi(str[3:5])
	year, _ := strconv.Atoi(str[6:8])
	hour, _ := strconv.Atoi(str[8:10])
	min, _ := strconv.Atoi(str[11:13])
	sec, _ := strconv.Atoi(str[14:16])
	parsedTime := time.Date(2000+year, time.Month(month), day, hour, min, sec, 0, &time.Location{})
	return parsedTime
}

//Парсинг время->timestamp
func time2Str(t time.Time) string {
	parsedStr := ""
	day := strconv.Itoa(t.Day())
	if len(day) < 2 {
		parsedStr += "0"
	}
	parsedStr += day + "-"
	month := strconv.Itoa(int(t.Month()))
	if len(month) < 2 {
		parsedStr += "0"
	}
	parsedStr += month + "-"
	year := strconv.Itoa(t.Year())
	parsedStr += year[2:] + " "
	hour := strconv.Itoa(t.Hour())
	if len(hour) < 2 {
		parsedStr += "0"
	}
	parsedStr += hour + ":"

	min := strconv.Itoa(t.Minute())
	if len(min) < 2 {
		parsedStr += "0"
	}
	parsedStr += min + ":"
	sec := strconv.Itoa(t.Second())
	if len(sec) < 2 {
		parsedStr += "0"
	}
	parsedStr += sec
	return parsedStr
}

//Чтение параметров запроса из txt
func readParams(filename string) (server string, tags []string, times []timePeriod, interval string) {
	buf, err := ioutil.ReadFile(filename)
	if err != nil {
		winmb.MessageBoxPlain(fmt.Sprintf("Ошибка чтения %s\n", filename), err.Error())
	}
	//notepad str ends with \r
	stroki := strings.Split(string(buf), "\r\n")
	for _, str := range stroki {
		str = strings.TrimSuffix(str, ";")
		if strings.Contains(str, "server:") {
			server = strings.TrimPrefix(
				strings.ReplaceAll(str, " ", ""), "server:")
		}
		if strings.Contains(str, "tags:") {
			tags = strings.Split(
				strings.TrimPrefix(
					strings.ReplaceAll(str, " ", ""), "tags:"), ";")
		}
		if strings.Contains(str, "interval") {
			interval = strings.TrimPrefix(
				strings.ReplaceAll(str, " ", ""), "interval:")
		}
		if strings.Contains(str, "times:") {
			periods := strings.Split(
				strings.TrimPrefix(str, "times:"), ";")
			for _, p := range periods {
				t := strings.Split(p, ",")
				times = append(times, timePeriod{t[0], t[1]})
			}
		}
	}
	return
}

//Сохраняем конфиг запроса в txt
func saveParams(filename string, server string, tags []string, times []timePeriod, interval string) {
	f, err := os.Create(filename)
	if err != nil {
		winmb.MessageBoxPlain(fmt.Sprintf("Ошибка создания %s", filename), err.Error())
	}
	defer f.Close()
	_, err = fmt.Fprintf(f, "server: %s\r\n", server)
	if err != nil {
		winmb.MessageBoxPlain(fmt.Sprintf("Ошибка записи в %s", filename), err.Error())
	}
	_, err = fmt.Fprintf(f, "tags: %s\r\n", strings.Join(tags, ";"))
	if err != nil {
		winmb.MessageBoxPlain(fmt.Sprintf("Ошибка записи в %s", filename), err.Error())
	}
	_, err = fmt.Fprint(f, "times: ")
	for _, t := range times {
		_, err = fmt.Fprintf(f, "%s, %s;", t.start, t.end)
	}
	_, err = fmt.Fprint(f, "\r\n")
	_, err = fmt.Fprintf(f, "interval: %s\r\n", interval)
	if err != nil {
		winmb.MessageBoxPlain(fmt.Sprintf("Ошибка записи в %s", filename), err.Error())
	}
}

//Экспорт в эксель
func export(data map[string][]sample) {
	xlFile := excelize.NewFile()
	defer xlFile.SaveAs("Выборка.xlsx")

	i := 1 //буквенная координата столбца
	var sheet = "Sheet1"
	xlFile.SetCellValue(sheet, "A1", "Timestamp")
	for tag, samples := range data {
		cellTag := string(alph[i]) + strconv.Itoa(1)
		xlFile.SetCellValue(sheet, cellTag, tag)

		var row int
		write := func(j int, sample sample) {
			//переход на новый лист при maxRows строк
			if row == maxRows {
				sheet = strconv.Itoa(j / maxRows)
				xlFile.NewSheet(sheet)
				row = 0
				xlFile.SetCellValue(sheet, "A1", "Timestamp")
				xlFile.SetCellValue(sheet, cellTag, tag)
			}
			//Запись процентов
			if (j%maxSamples == 0) && (j != 0) {
				totalPerc += percent
				workPercent <- totalPerc
			}
			//Пишем время только для 1 тэга
			if i == 1 {
				cellTime := string(alph[0]) + strconv.Itoa(row+2)
				xlFile.SetCellValue(sheet, cellTime, sample.timestamp)
			}

			cellValue := string(alph[i]) + strconv.Itoa(row+2)
			xlFile.SetCellValue(sheet, cellValue, sample.value)

			row++
		}

		for j, sample := range samples {
			select {
			case stop := <-stopChan:
				if stop {
					return
				}
				write(j, sample)
			default:
				write(j, sample)
			}
		}

		i++
		sheet = "Sheet1"
	}
}
