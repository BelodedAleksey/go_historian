package main

import (
	"io/ioutil"
	"log"
	"strconv"
	"strings"
	"time"

	"github.com/360EntSecGroup-Skylar/excelize"
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
func readParams() (server string, tags []string, times []timePeriod, interval string) {
	buf, err := ioutil.ReadFile("params.txt")
	if err != nil {
		log.Println("Error read params.txt", err.Error())
	}
	stroki := strings.Split(string(buf), "\n")
	for _, str := range stroki {
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

//Экспорт в эксель
func export(data map[string][]sample) {
	//чтение
	xlFile := excelize.NewFile()
	defer xlFile.SaveAs("Выборка.xlsx")

	i := 1 //буквенная координата столбца
	xlFile.SetCellValue("Sheet1", "A1", "Timestamp")
	for tag, samples := range data {
		cellTag := string(alph[i]) + strconv.Itoa(1)
		xlFile.SetCellValue("Sheet1", cellTag, tag)

		for j, sample := range samples {
			cellTime := string(alph[0]) + strconv.Itoa(j+2)
			cellValue := string(alph[i]) + strconv.Itoa(j+2)
			xlFile.SetCellValue("Sheet1", cellTime, sample.timestamp)
			xlFile.SetCellValue("Sheet1", cellValue, sample.value)
		}

		i++
	}
}
