import '../models/models.dart';

// Сортировка марок: лексикографическая по первому символу.
// Цифры (0–9) → кириллица (А–Я) → латиница (A–Z).
// Применяется ко всем группам металлов.

const List<MetalMaterial> materials = [

  // ── СТАЛЬ ────────────────────────────────────────────────────────────────────
  MetalMaterial(group: 'Сталь', grade: '08',       density: 7850, gost: 'ГОСТ 1050-2013'),
  MetalMaterial(group: 'Сталь', grade: '08пс',     density: 7850, gost: 'ГОСТ 1050-2013'),
  MetalMaterial(group: 'Сталь', grade: '09Г2С',    density: 7850, gost: 'ГОСТ 19281-2014'),
  MetalMaterial(group: 'Сталь', grade: '10',       density: 7850, gost: 'ГОСТ 1050-2013'),
  MetalMaterial(group: 'Сталь', grade: '10Г2',     density: 7850, gost: 'ГОСТ 19281-2014'),
  MetalMaterial(group: 'Сталь', grade: '10Г2С1',   density: 7850, gost: 'ГОСТ 19281-2014'),
  MetalMaterial(group: 'Сталь', grade: '10ХСНД',   density: 7850, gost: 'ГОСТ 19281-2014'),
  MetalMaterial(group: 'Сталь', grade: '12ХН2',    density: 7850, gost: 'ГОСТ 4543-2016'),
  MetalMaterial(group: 'Сталь', grade: '12ХН3А',   density: 7850, gost: 'ГОСТ 4543-2016'),
  MetalMaterial(group: 'Сталь', grade: '14Г2',     density: 7850, gost: 'ГОСТ 19281-2014'),
  MetalMaterial(group: 'Сталь', grade: '15',       density: 7850, gost: 'ГОСТ 1050-2013'),
  MetalMaterial(group: 'Сталь', grade: '15Г2СФ',   density: 7850, gost: 'ГОСТ 19281-2014'),
  MetalMaterial(group: 'Сталь', grade: '15Х',      density: 7850, gost: 'ГОСТ 4543-2016'),
  MetalMaterial(group: 'Сталь', grade: '15ХА',     density: 7850, gost: 'ГОСТ 4543-2016'),
  MetalMaterial(group: 'Сталь', grade: '15ХСНД',   density: 7850, gost: 'ГОСТ 19281-2014'),
  MetalMaterial(group: 'Сталь', grade: '16Г2АФ',   density: 7850, gost: 'ГОСТ 19281-2014'),
  MetalMaterial(group: 'Сталь', grade: '17Г1С',    density: 7850, gost: 'ГОСТ 19281-2014'),
  MetalMaterial(group: 'Сталь', grade: '18ХГТ',    density: 7850, gost: 'ГОСТ 4543-2016'),
  MetalMaterial(group: 'Сталь', grade: '20',       density: 7850, gost: 'ГОСТ 1050-2013'),
  MetalMaterial(group: 'Сталь', grade: '20Х',      density: 7850, gost: 'ГОСТ 4543-2016'),
  MetalMaterial(group: 'Сталь', grade: '20ХГНМ',   density: 7850, gost: 'ГОСТ 4543-2016'),
  MetalMaterial(group: 'Сталь', grade: '20ХГС2',   density: 7850, gost: 'ГОСТ 4543-2016'),
  MetalMaterial(group: 'Сталь', grade: '20ХН',     density: 7850, gost: 'ГОСТ 4543-2016'),
  MetalMaterial(group: 'Сталь', grade: '20ХН3А',   density: 7850, gost: 'ГОСТ 4543-2016'),
  MetalMaterial(group: 'Сталь', grade: '20ХНМ',    density: 7850, gost: 'ГОСТ 4543-2016'),
  MetalMaterial(group: 'Сталь', grade: '25',       density: 7850, gost: 'ГОСТ 1050-2013'),
  MetalMaterial(group: 'Сталь', grade: '25Х',      density: 7850, gost: 'ГОСТ 4543-2016'),
  MetalMaterial(group: 'Сталь', grade: '25ХГТ',    density: 7850, gost: 'ГОСТ 4543-2016'),
  MetalMaterial(group: 'Сталь', grade: '30',       density: 7850, gost: 'ГОСТ 1050-2013'),
  MetalMaterial(group: 'Сталь', grade: '30Х',      density: 7850, gost: 'ГОСТ 4543-2016'),
  MetalMaterial(group: 'Сталь', grade: '30ХГТ',    density: 7850, gost: 'ГОСТ 4543-2016'),
  MetalMaterial(group: 'Сталь', grade: '30ХГСА',   density: 7850, gost: 'ГОСТ 4543-2016'),
  MetalMaterial(group: 'Сталь', grade: '30ХН3А',   density: 7850, gost: 'ГОСТ 4543-2016'),
  MetalMaterial(group: 'Сталь', grade: '35',       density: 7850, gost: 'ГОСТ 1050-2013'),
  MetalMaterial(group: 'Сталь', grade: '35Х',      density: 7850, gost: 'ГОСТ 4543-2016'),
  MetalMaterial(group: 'Сталь', grade: '35ХГФ',    density: 7850, gost: 'ГОСТ 4543-2016'),
  MetalMaterial(group: 'Сталь', grade: '35ХМ',     density: 7850, gost: 'ГОСТ 4543-2016'),
  MetalMaterial(group: 'Сталь', grade: '38ХМА',    density: 7850, gost: 'ГОСТ 4543-2016'),
  MetalMaterial(group: 'Сталь', grade: '38ХС',     density: 7850, gost: 'ГОСТ 4543-2016'),
  MetalMaterial(group: 'Сталь', grade: '40',       density: 7850, gost: 'ГОСТ 1050-2013'),
  MetalMaterial(group: 'Сталь', grade: '40Х',      density: 7850, gost: 'ГОСТ 4543-2016'),
  MetalMaterial(group: 'Сталь', grade: '40ХМ',     density: 7850, gost: 'ГОСТ 4543-2016'),
  MetalMaterial(group: 'Сталь', grade: '40ХН',     density: 7850, gost: 'ГОСТ 4543-2016'),
  MetalMaterial(group: 'Сталь', grade: '40ХНМ',    density: 7850, gost: 'ГОСТ 4543-2016'),
  MetalMaterial(group: 'Сталь', grade: '40ХФА',    density: 7850, gost: 'ГОСТ 4543-2016'),
  MetalMaterial(group: 'Сталь', grade: '45',       density: 7850, gost: 'ГОСТ 1050-2013'),
  MetalMaterial(group: 'Сталь', grade: '45Х',      density: 7850, gost: 'ГОСТ 4543-2016'),
  MetalMaterial(group: 'Сталь', grade: '45ХН',     density: 7850, gost: 'ГОСТ 4543-2016'),
  MetalMaterial(group: 'Сталь', grade: '4ХВ2С',    density: 7830, gost: 'ГОСТ 5950-2000'),
  MetalMaterial(group: 'Сталь', grade: '50',       density: 7850, gost: 'ГОСТ 1050-2013'),
  MetalMaterial(group: 'Сталь', grade: '50Х',      density: 7850, gost: 'ГОСТ 4543-2016'),
  MetalMaterial(group: 'Сталь', grade: '50ХГА',    density: 7850, gost: 'ГОСТ 14959-2016'),
  MetalMaterial(group: 'Сталь', grade: '50ХФА',    density: 7850, gost: 'ГОСТ 14959-2016'),
  MetalMaterial(group: 'Сталь', grade: '55',       density: 7850, gost: 'ГОСТ 1050-2013'),
  MetalMaterial(group: 'Сталь', grade: '55С2',     density: 7850, gost: 'ГОСТ 14959-2016'),
  MetalMaterial(group: 'Сталь', grade: '55ХГР',    density: 7850, gost: 'ГОСТ 14959-2016'),
  MetalMaterial(group: 'Сталь', grade: '58',       density: 7850, gost: 'ГОСТ 1050-2013'),
  MetalMaterial(group: 'Сталь', grade: '5ХВ2С',    density: 7830, gost: 'ГОСТ 5950-2000'),
  MetalMaterial(group: 'Сталь', grade: '60',       density: 7850, gost: 'ГОСТ 1050-2013'),
  MetalMaterial(group: 'Сталь', grade: '60Г',      density: 7850, gost: 'ГОСТ 14959-2016'),
  MetalMaterial(group: 'Сталь', grade: '60С2',     density: 7850, gost: 'ГОСТ 14959-2016'),
  MetalMaterial(group: 'Сталь', grade: '60С2А',    density: 7850, gost: 'ГОСТ 14959-2016'),
  MetalMaterial(group: 'Сталь', grade: '65',       density: 7850, gost: 'ГОСТ 14959-2016'),
  MetalMaterial(group: 'Сталь', grade: '65Г',      density: 7850, gost: 'ГОСТ 14959-2016'),
  MetalMaterial(group: 'Сталь', grade: '6ХВ2С',    density: 7830, gost: 'ГОСТ 5950-2000'),
  MetalMaterial(group: 'Сталь', grade: '70',       density: 7850, gost: 'ГОСТ 14959-2016'),
  MetalMaterial(group: 'Сталь', grade: '70С3А',    density: 7850, gost: 'ГОСТ 14959-2016'),
  MetalMaterial(group: 'Сталь', grade: '7ХГ2ВМФ',  density: 7830, gost: 'ГОСТ 5950-2000'),
  MetalMaterial(group: 'Сталь', grade: '9ХС',      density: 7830, gost: 'ГОСТ 5950-2000'),
  MetalMaterial(group: 'Сталь', grade: 'А12',      density: 7850, gost: 'ГОСТ 1414-75'),
  MetalMaterial(group: 'Сталь', grade: 'А20',      density: 7850, gost: 'ГОСТ 1414-75'),
  MetalMaterial(group: 'Сталь', grade: 'А30',      density: 7850, gost: 'ГОСТ 1414-75'),
  MetalMaterial(group: 'Сталь', grade: 'А35',      density: 7850, gost: 'ГОСТ 1414-75'),
  MetalMaterial(group: 'Сталь', grade: 'А40Г',     density: 7850, gost: 'ГОСТ 1414-75'),
  MetalMaterial(group: 'Сталь', grade: 'Р12Ф3',    density: 8150, gost: 'ГОСТ 19265-73'),
  MetalMaterial(group: 'Сталь', grade: 'Р18',      density: 8700, gost: 'ГОСТ 19265-73'),
  MetalMaterial(group: 'Сталь', grade: 'Р18Ф2К5',  density: 8800, gost: 'ГОСТ 19265-73'),
  MetalMaterial(group: 'Сталь', grade: 'Р6М5',     density: 8150, gost: 'ГОСТ 19265-73'),
  MetalMaterial(group: 'Сталь', grade: 'Р6М5К5',   density: 8200, gost: 'ГОСТ 19265-73'),
  MetalMaterial(group: 'Сталь', grade: 'Р6М5Ф3',   density: 8150, gost: 'ГОСТ 19265-73'),
  MetalMaterial(group: 'Сталь', grade: 'Р9',       density: 8500, gost: 'ГОСТ 19265-73'),
  MetalMaterial(group: 'Сталь', grade: 'Р9К10',    density: 8600, gost: 'ГОСТ 19265-73'),
  MetalMaterial(group: 'Сталь', grade: 'Р9К5',     density: 8550, gost: 'ГОСТ 19265-73'),
  MetalMaterial(group: 'Сталь', grade: 'Р9Ф5',     density: 8500, gost: 'ГОСТ 19265-73'),
  MetalMaterial(group: 'Сталь', grade: 'Ст0',      density: 7850, gost: 'ГОСТ 380-2005'),
  MetalMaterial(group: 'Сталь', grade: 'Ст1кп',    density: 7850, gost: 'ГОСТ 380-2005'),
  MetalMaterial(group: 'Сталь', grade: 'Ст1пс',    density: 7850, gost: 'ГОСТ 380-2005'),
  MetalMaterial(group: 'Сталь', grade: 'Ст1сп',    density: 7850, gost: 'ГОСТ 380-2005'),
  MetalMaterial(group: 'Сталь', grade: 'Ст2кп',    density: 7850, gost: 'ГОСТ 380-2005'),
  MetalMaterial(group: 'Сталь', grade: 'Ст2пс',    density: 7850, gost: 'ГОСТ 380-2005'),
  MetalMaterial(group: 'Сталь', grade: 'Ст2сп',    density: 7850, gost: 'ГОСТ 380-2005'),
  MetalMaterial(group: 'Сталь', grade: 'Ст3Гпс',   density: 7850, gost: 'ГОСТ 380-2005'),
  MetalMaterial(group: 'Сталь', grade: 'Ст3Гсп',   density: 7850, gost: 'ГОСТ 380-2005'),
  MetalMaterial(group: 'Сталь', grade: 'Ст3кп',    density: 7850, gost: 'ГОСТ 380-2005'),
  MetalMaterial(group: 'Сталь', grade: 'Ст3пс',    density: 7850, gost: 'ГОСТ 380-2005'),
  MetalMaterial(group: 'Сталь', grade: 'Ст3сп',    density: 7850, gost: 'ГОСТ 380-2005'),
  MetalMaterial(group: 'Сталь', grade: 'Ст4кп',    density: 7850, gost: 'ГОСТ 380-2005'),
  MetalMaterial(group: 'Сталь', grade: 'Ст4пс',    density: 7850, gost: 'ГОСТ 380-2005'),
  MetalMaterial(group: 'Сталь', grade: 'Ст4сп',    density: 7850, gost: 'ГОСТ 380-2005'),
  MetalMaterial(group: 'Сталь', grade: 'Ст5пс',    density: 7850, gost: 'ГОСТ 380-2005'),
  MetalMaterial(group: 'Сталь', grade: 'Ст5сп',    density: 7850, gost: 'ГОСТ 380-2005'),
  MetalMaterial(group: 'Сталь', grade: 'Ст6пс',    density: 7850, gost: 'ГОСТ 380-2005'),
  MetalMaterial(group: 'Сталь', grade: 'Ст6сп',    density: 7850, gost: 'ГОСТ 380-2005'),
  MetalMaterial(group: 'Сталь', grade: 'У10',      density: 7830, gost: 'ГОСТ 1435-99'),
  MetalMaterial(group: 'Сталь', grade: 'У10А',     density: 7830, gost: 'ГОСТ 1435-99'),
  MetalMaterial(group: 'Сталь', grade: 'У11',      density: 7830, gost: 'ГОСТ 1435-99'),
  MetalMaterial(group: 'Сталь', grade: 'У11А',     density: 7830, gost: 'ГОСТ 1435-99'),
  MetalMaterial(group: 'Сталь', grade: 'У12',      density: 7830, gost: 'ГОСТ 1435-99'),
  MetalMaterial(group: 'Сталь', grade: 'У12А',     density: 7830, gost: 'ГОСТ 1435-99'),
  MetalMaterial(group: 'Сталь', grade: 'У13',      density: 7830, gost: 'ГОСТ 1435-99'),
  MetalMaterial(group: 'Сталь', grade: 'У13А',     density: 7830, gost: 'ГОСТ 1435-99'),
  MetalMaterial(group: 'Сталь', grade: 'У7',       density: 7830, gost: 'ГОСТ 1435-99'),
  MetalMaterial(group: 'Сталь', grade: 'У7А',      density: 7830, gost: 'ГОСТ 1435-99'),
  MetalMaterial(group: 'Сталь', grade: 'У8',       density: 7830, gost: 'ГОСТ 1435-99'),
  MetalMaterial(group: 'Сталь', grade: 'У8А',      density: 7830, gost: 'ГОСТ 1435-99'),
  MetalMaterial(group: 'Сталь', grade: 'У9',       density: 7830, gost: 'ГОСТ 1435-99'),
  MetalMaterial(group: 'Сталь', grade: 'У9А',      density: 7830, gost: 'ГОСТ 1435-99'),
  MetalMaterial(group: 'Сталь', grade: 'Х',        density: 7830, gost: 'ГОСТ 5950-2000'),
  MetalMaterial(group: 'Сталь', grade: 'Х12',      density: 7700, gost: 'ГОСТ 5950-2000'),
  MetalMaterial(group: 'Сталь', grade: 'Х12МФ',    density: 7700, gost: 'ГОСТ 5950-2000'),
  MetalMaterial(group: 'Сталь', grade: 'Х12Ф1',    density: 7700, gost: 'ГОСТ 5950-2000'),
  MetalMaterial(group: 'Сталь', grade: 'Х5МФ',     density: 7830, gost: 'ГОСТ 5950-2000'),
  MetalMaterial(group: 'Сталь', grade: 'Х6ВФ',     density: 7830, gost: 'ГОСТ 5950-2000'),
  MetalMaterial(group: 'Сталь', grade: 'ХВГ',      density: 7830, gost: 'ГОСТ 5950-2000'),
  MetalMaterial(group: 'Сталь', grade: 'ХВ4Ф',     density: 7830, gost: 'ГОСТ 5950-2000'),

  // ── НЕРЖАВЕЙКА ───────────────────────────────────────────────────────────────
  MetalMaterial(group: 'Нержавейка', grade: '02Х18Н11',          density: 7900, gost: 'ГОСТ 5632-2014'),
  MetalMaterial(group: 'Нержавейка', grade: '03Х16Н15М3',        density: 8000, gost: 'ГОСТ 5632-2014'),
  MetalMaterial(group: 'Нержавейка', grade: '03Х17Н14М3 (316L)', density: 7980, gost: 'ГОСТ 5632-2014'),
  MetalMaterial(group: 'Нержавейка', grade: '03Х18Н11',          density: 7900, gost: 'ГОСТ 5632-2014'),
  MetalMaterial(group: 'Нержавейка', grade: '04Х18Н10',          density: 7900, gost: 'ГОСТ 5632-2014'),
  MetalMaterial(group: 'Нержавейка', grade: '06ХН28МДТ',         density: 7980, gost: 'ГОСТ 5632-2014'),
  MetalMaterial(group: 'Нержавейка', grade: '07Х16Н6',           density: 7800, gost: 'ГОСТ 5632-2014'),
  MetalMaterial(group: 'Нержавейка', grade: '08Х13',             density: 7750, gost: 'ГОСТ 5632-2014'),
  MetalMaterial(group: 'Нержавейка', grade: '08Х18Н10 (304)',    density: 7930, gost: 'ГОСТ 5632-2014'),
  MetalMaterial(group: 'Нержавейка', grade: '08Х18Н10Т (321)',   density: 7900, gost: 'ГОСТ 5632-2014'),
  MetalMaterial(group: 'Нержавейка', grade: '08Х22Н6Т',          density: 7800, gost: 'ГОСТ 5632-2014'),
  MetalMaterial(group: 'Нержавейка', grade: '09Х16Н4Б',          density: 7750, gost: 'ГОСТ 5632-2014'),
  MetalMaterial(group: 'Нержавейка', grade: '10Х13Г18Д',         density: 7800, gost: 'ГОСТ 5632-2014'),
  MetalMaterial(group: 'Нержавейка', grade: '10Х17Н13М2Т (316)', density: 8000, gost: 'ГОСТ 5632-2014'),
  MetalMaterial(group: 'Нержавейка', grade: '10Х23Н18',          density: 7900, gost: 'ГОСТ 5632-2014'),
  MetalMaterial(group: 'Нержавейка', grade: '12Х13 (410)',        density: 7750, gost: 'ГОСТ 5632-2014'),
  MetalMaterial(group: 'Нержавейка', grade: '12Х17 (430)',        density: 7700, gost: 'ГОСТ 5632-2014'),
  MetalMaterial(group: 'Нержавейка', grade: '12Х18Н10Т',         density: 7900, gost: 'ГОСТ 5632-2014'),
  MetalMaterial(group: 'Нержавейка', grade: '12Х18Н9',           density: 7900, gost: 'ГОСТ 5632-2014'),
  MetalMaterial(group: 'Нержавейка', grade: '14Х17Н2 (431)',     density: 7750, gost: 'ГОСТ 5632-2014'),
  MetalMaterial(group: 'Нержавейка', grade: '15Х25Т (446)',      density: 7600, gost: 'ГОСТ 5632-2014'),
  MetalMaterial(group: 'Нержавейка', grade: '15Х5М',             density: 7750, gost: 'ГОСТ 5632-2014'),
  MetalMaterial(group: 'Нержавейка', grade: '17Х18Н9',           density: 7900, gost: 'ГОСТ 5632-2014'),
  MetalMaterial(group: 'Нержавейка', grade: '20Х13 (420)',        density: 7750, gost: 'ГОСТ 5632-2014'),
  MetalMaterial(group: 'Нержавейка', grade: '20Х17Н2',           density: 7750, gost: 'ГОСТ 5632-2014'),
  MetalMaterial(group: 'Нержавейка', grade: '20Х23Н18',          density: 7900, gost: 'ГОСТ 5632-2014'),
  MetalMaterial(group: 'Нержавейка', grade: '25Х13Н2',           density: 7800, gost: 'ГОСТ 5632-2014'),
  MetalMaterial(group: 'Нержавейка', grade: '30Х13',             density: 7750, gost: 'ГОСТ 5632-2014'),
  MetalMaterial(group: 'Нержавейка', grade: '40Х13',             density: 7650, gost: 'ГОСТ 5632-2014'),
  MetalMaterial(group: 'Нержавейка', grade: 'AISI 201',          density: 7800, gost: 'AISI/ASTM'),
  MetalMaterial(group: 'Нержавейка', grade: 'AISI 304',          density: 7930, gost: 'AISI/ASTM'),
  MetalMaterial(group: 'Нержавейка', grade: 'AISI 316',          density: 7980, gost: 'AISI/ASTM'),
  MetalMaterial(group: 'Нержавейка', grade: 'AISI 316L',         density: 7980, gost: 'AISI/ASTM'),
  MetalMaterial(group: 'Нержавейка', grade: 'AISI 321',          density: 7900, gost: 'AISI/ASTM'),
  MetalMaterial(group: 'Нержавейка', grade: 'AISI 430',          density: 7700, gost: 'AISI/ASTM'),

  // ── АЛЮМИНИЙ ─────────────────────────────────────────────────────────────────
  MetalMaterial(group: 'Алюминий', grade: '1561',      density: 2660, gost: 'ГОСТ 4784-2019'),
  MetalMaterial(group: 'Алюминий', grade: '1915',      density: 2830, gost: 'ГОСТ 4784-2019'),
  MetalMaterial(group: 'Алюминий', grade: '1950',      density: 2840, gost: 'ГОСТ 4784-2019'),
  MetalMaterial(group: 'Алюминий', grade: '6061',      density: 2700, gost: 'ASTM B209'),
  MetalMaterial(group: 'Алюминий', grade: '6082',      density: 2710, gost: 'EN 755'),
  MetalMaterial(group: 'Алюминий', grade: '7075 (В95)',density: 2810, gost: 'ASTM B209'),
  MetalMaterial(group: 'Алюминий', grade: 'А5',        density: 2700, gost: 'ГОСТ 11069-2019'),
  MetalMaterial(group: 'Алюминий', grade: 'АВ',        density: 2700, gost: 'ГОСТ 4784-2019'),
  MetalMaterial(group: 'Алюминий', grade: 'АД0',       density: 2710, gost: 'ГОСТ 4784-2019'),
  MetalMaterial(group: 'Алюминий', grade: 'АД1',       density: 2710, gost: 'ГОСТ 4784-2019'),
  MetalMaterial(group: 'Алюминий', grade: 'АД31',      density: 2710, gost: 'ГОСТ 4784-2019'),
  MetalMaterial(group: 'Алюминий', grade: 'АК4',       density: 2800, gost: 'ГОСТ 4784-2019'),
  MetalMaterial(group: 'Алюминий', grade: 'АК6',       density: 2750, gost: 'ГОСТ 4784-2019'),
  MetalMaterial(group: 'Алюминий', grade: 'АК8',       density: 2800, gost: 'ГОСТ 4784-2019'),
  MetalMaterial(group: 'Алюминий', grade: 'АМг2',      density: 2680, gost: 'ГОСТ 4784-2019'),
  MetalMaterial(group: 'Алюминий', grade: 'АМг3',      density: 2670, gost: 'ГОСТ 4784-2019'),
  MetalMaterial(group: 'Алюминий', grade: 'АМг5',      density: 2650, gost: 'ГОСТ 4784-2019'),
  MetalMaterial(group: 'Алюминий', grade: 'АМг6',      density: 2640, gost: 'ГОСТ 4784-2019'),
  MetalMaterial(group: 'Алюминий', grade: 'АМц',       density: 2730, gost: 'ГОСТ 4784-2019'),
  MetalMaterial(group: 'Алюминий', grade: 'В93',       density: 2850, gost: 'ГОСТ 4784-2019'),
  MetalMaterial(group: 'Алюминий', grade: 'В95',       density: 2850, gost: 'ГОСТ 4784-2019'),
  MetalMaterial(group: 'Алюминий', grade: 'В96Ц',      density: 2850, gost: 'ГОСТ 4784-2019'),
  MetalMaterial(group: 'Алюминий', grade: 'Д1',        density: 2790, gost: 'ГОСТ 4784-2019'),
  MetalMaterial(group: 'Алюминий', grade: 'Д16',       density: 2780, gost: 'ГОСТ 4784-2019'),
  MetalMaterial(group: 'Алюминий', grade: 'Д16Т',      density: 2780, gost: 'ГОСТ 4784-2019'),
  MetalMaterial(group: 'Алюминий', grade: 'Д19',       density: 2780, gost: 'ГОСТ 4784-2019'),

  // ── ЛАТУНЬ ───────────────────────────────────────────────────────────────────
  MetalMaterial(group: 'Латунь', grade: 'Л63',        density: 8440, gost: 'ГОСТ 15527-2004'),
  MetalMaterial(group: 'Латунь', grade: 'Л68',        density: 8600, gost: 'ГОСТ 15527-2004'),
  MetalMaterial(group: 'Латунь', grade: 'Л80',        density: 8660, gost: 'ГОСТ 15527-2004'),
  MetalMaterial(group: 'Латунь', grade: 'Л90',        density: 8780, gost: 'ГОСТ 15527-2004'),
  MetalMaterial(group: 'Латунь', grade: 'Л96',        density: 8850, gost: 'ГОСТ 15527-2004'),
  MetalMaterial(group: 'Латунь', grade: 'ЛА77-2',     density: 8600, gost: 'ГОСТ 15527-2004'),
  MetalMaterial(group: 'Латунь', grade: 'ЛАЖ60-1-1',  density: 8200, gost: 'ГОСТ 15527-2004'),
  MetalMaterial(group: 'Латунь', grade: 'ЛЖМц59-1-1', density: 8500, gost: 'ГОСТ 15527-2004'),
  MetalMaterial(group: 'Латунь', grade: 'ЛМц58-2',    density: 8400, gost: 'ГОСТ 15527-2004'),
  MetalMaterial(group: 'Латунь', grade: 'ЛН65-5',     density: 8500, gost: 'ГОСТ 15527-2004'),
  MetalMaterial(group: 'Латунь', grade: 'ЛО62-1',     density: 8500, gost: 'ГОСТ 15527-2004'),
  MetalMaterial(group: 'Латунь', grade: 'ЛС59-1',     density: 8500, gost: 'ГОСТ 15527-2004'),

  // ── МЕДЬ ─────────────────────────────────────────────────────────────────────
  MetalMaterial(group: 'Медь', grade: 'М00',  density: 8940, gost: 'ГОСТ 859-2014'),
  MetalMaterial(group: 'Медь', grade: 'М00б', density: 8940, gost: 'ГОСТ 859-2014'),
  MetalMaterial(group: 'Медь', grade: 'М0',   density: 8940, gost: 'ГОСТ 859-2014'),
  MetalMaterial(group: 'Медь', grade: 'М0б',  density: 8940, gost: 'ГОСТ 859-2014'),
  MetalMaterial(group: 'Медь', grade: 'М1',   density: 8900, gost: 'ГОСТ 859-2014'),
  MetalMaterial(group: 'Медь', grade: 'М1б',  density: 8900, gost: 'ГОСТ 859-2014'),
  MetalMaterial(group: 'Медь', grade: 'М1р',  density: 8900, gost: 'ГОСТ 859-2014'),
  MetalMaterial(group: 'Медь', grade: 'М2',   density: 8900, gost: 'ГОСТ 859-2014'),
  MetalMaterial(group: 'Медь', grade: 'М3',   density: 8900, gost: 'ГОСТ 859-2014'),
  MetalMaterial(group: 'Медь', grade: 'М4',   density: 8900, gost: 'ГОСТ 859-2014'),

  // ── БРОНЗА ───────────────────────────────────────────────────────────────────
  MetalMaterial(group: 'Бронза', grade: 'БрАЖ9-4',      density: 7600, gost: 'ГОСТ 18175-78'),
  MetalMaterial(group: 'Бронза', grade: 'БрАЖН10-4-4',  density: 7500, gost: 'ГОСТ 18175-78'),
  MetalMaterial(group: 'Бронза', grade: 'БрАМц9-2',     density: 7600, gost: 'ГОСТ 18175-78'),
  MetalMaterial(group: 'Бронза', grade: 'БрБ2',         density: 8200, gost: 'ГОСТ 18175-78'),
  MetalMaterial(group: 'Бронза', grade: 'БрКМц3-1',     density: 8400, gost: 'ГОСТ 18175-78'),
  MetalMaterial(group: 'Бронза', grade: 'БрКН1-3',      density: 8800, gost: 'ГОСТ 18175-78'),
  MetalMaterial(group: 'Бронза', grade: 'БрМц5',        density: 8600, gost: 'ГОСТ 18175-78'),
  MetalMaterial(group: 'Бронза', grade: 'БрОФ10-1',     density: 8780, gost: 'ГОСТ 18175-78'),
  MetalMaterial(group: 'Бронза', grade: 'БрОЦС4-4-2.5', density: 8900, gost: 'ГОСТ 18175-78'),

  // ── ВОЛЬФРАМ ─────────────────────────────────────────────────────────────────
  MetalMaterial(group: 'Вольфрам', grade: 'ВА',  density: 19100, gost: 'ГОСТ 19335-73'),
  MetalMaterial(group: 'Вольфрам', grade: 'ВАН', density: 19200, gost: 'ГОСТ 19335-73'),

  // ── МОЛИБДЕН ─────────────────────────────────────────────────────────────────
  MetalMaterial(group: 'Молибден', grade: 'МВ', density: 10200, gost: 'ГОСТ 17431-72'),
  MetalMaterial(group: 'Молибден', grade: 'МЧ', density: 10200, gost: 'ГОСТ 17431-72'),

  // ── НИКЕЛЬ ───────────────────────────────────────────────────────────────────
  MetalMaterial(group: 'Никель', grade: 'ВНМ3-2',      density: 8900,  gost: 'ТУ 48-19-90-90'),
  MetalMaterial(group: 'Никель', grade: 'Inconel 625', density: 8440,  gost: 'ASTM B446'),
  MetalMaterial(group: 'Никель', grade: 'МН19',         density: 8900,  gost: 'ГОСТ 492-2006'),
  MetalMaterial(group: 'Никель', grade: 'МНЖМц30-1-1', density: 8900,  gost: 'ГОСТ 492-2006'),
  MetalMaterial(group: 'Никель', grade: 'МНМц43-0.5',  density: 8900,  gost: 'ГОСТ 492-2006'),
  MetalMaterial(group: 'Никель', grade: 'МНЦ15-20',    density: 8700,  gost: 'ГОСТ 492-2006'),
  MetalMaterial(group: 'Никель', grade: 'НП1',         density: 8900,  gost: 'ГОСТ 492-2006'),
  MetalMaterial(group: 'Никель', grade: 'НП2',         density: 8900,  gost: 'ГОСТ 492-2006'),
  MetalMaterial(group: 'Никель', grade: 'НП3',         density: 8900,  gost: 'ГОСТ 492-2006'),
  MetalMaterial(group: 'Никель', grade: 'НП4',         density: 8900,  gost: 'ГОСТ 492-2006'),

  // ── НИХРОМ ───────────────────────────────────────────────────────────────────
  MetalMaterial(group: 'Нихром', grade: 'Х15Н60', density: 8200, gost: 'ГОСТ 10994-74'),
  MetalMaterial(group: 'Нихром', grade: 'Х20Н80', density: 8400, gost: 'ГОСТ 10994-74'),
  MetalMaterial(group: 'Нихром', grade: 'ХН70Ю',  density: 8200, gost: 'ГОСТ 10994-74'),
  MetalMaterial(group: 'Нихром', grade: 'Х23Ю5Т', density: 7250, gost: 'ГОСТ 10994-74'),

  // ── ТИТАН ────────────────────────────────────────────────────────────────────
  MetalMaterial(group: 'Титан', grade: 'ВТ1-0',      density: 4510, gost: 'ГОСТ 19807-91'),
  MetalMaterial(group: 'Титан', grade: 'ВТ1-00',     density: 4505, gost: 'ГОСТ 19807-91'),
  MetalMaterial(group: 'Титан', grade: 'ВТ14',       density: 4420, gost: 'ГОСТ 19807-91'),
  MetalMaterial(group: 'Титан', grade: 'ВТ20',       density: 4450, gost: 'ГОСТ 19807-91'),
  MetalMaterial(group: 'Титан', grade: 'ВТ22',       density: 4630, gost: 'ГОСТ 19807-91'),
  MetalMaterial(group: 'Титан', grade: 'ВТ3-1',      density: 4500, gost: 'ГОСТ 19807-91'),
  MetalMaterial(group: 'Титан', grade: 'ВТ5',        density: 4510, gost: 'ГОСТ 19807-91'),
  MetalMaterial(group: 'Титан', grade: 'ВТ5-1',      density: 4460, gost: 'ГОСТ 19807-91'),
  MetalMaterial(group: 'Титан', grade: 'ВТ6',        density: 4430, gost: 'ГОСТ 19807-91'),
  MetalMaterial(group: 'Титан', grade: 'ВТ8',        density: 4500, gost: 'ГОСТ 19807-91'),
  MetalMaterial(group: 'Титан', grade: 'ВТ9',        density: 4500, gost: 'ГОСТ 19807-91'),
  MetalMaterial(group: 'Титан', grade: 'ОТ4',        density: 4500, gost: 'ГОСТ 19807-91'),
  MetalMaterial(group: 'Титан', grade: 'ПТ-3В',      density: 4510, gost: 'ГОСТ 19807-91'),
  MetalMaterial(group: 'Титан', grade: 'ПТ-7М',      density: 4510, gost: 'ГОСТ 19807-91'),
  MetalMaterial(group: 'Титан', grade: 'Ti Grade 2', density: 4510, gost: 'ASTM B265'),
  MetalMaterial(group: 'Титан', grade: 'Ti Grade 5', density: 4430, gost: 'ASTM B265'),

  // ── ЦИНК ─────────────────────────────────────────────────────────────────────
  MetalMaterial(group: 'Цинк', grade: 'Ц0', density: 7133, gost: 'ГОСТ 3640-94'),
  MetalMaterial(group: 'Цинк', grade: 'Ц1', density: 7133, gost: 'ГОСТ 3640-94'),
  MetalMaterial(group: 'Цинк', grade: 'Ц2', density: 7133, gost: 'ГОСТ 3640-94'),
  MetalMaterial(group: 'Цинк', grade: 'Ц3', density: 7133, gost: 'ГОСТ 3640-94'),
  MetalMaterial(group: 'Цинк', grade: 'Ц4', density: 7133, gost: 'ГОСТ 3640-94'),

  // ── ЦИРКОНИЙ ─────────────────────────────────────────────────────────────────
  MetalMaterial(group: 'Цирконий', grade: 'ЦрНб-1', density: 6510, gost: 'ГОСТ 21907-76'),
];

// Порядок видов металла — по частоте выдач со склада (xlsx 05.05.26).
// Металлы без остатков сдвинуты вниз и отсортированы по алфавиту.
const List<String> _groupOrder = [
  // Есть в остатках (по убыванию частоты)
  'Сталь',        // 20, 45, 35, А12, 30ХГСА, Ст3сп...
  'Латунь',       // ЛС59-1, Л63
  'Медь',         // М (лист, лента)
  'Бронза',       // БрКМц3-1, БрБ2
  'Алюминий',     // АМг2, Д16, АМг6, АД1, АМг3...
  'Нержавейка',   // 25Х13Н2, 12Х18Н10Т, 14Х17Н2
  // Нет в остатках (по алфавиту)
  'Вольфрам',
  'Молибден',
  'Никель',
  'Нихром',
  'Титан',
  'Цинк',
  'Цирконий',
];

List<String> get metalGroups {
  final seen = <String>{};
  final result = <String>[];
  for (final g in _groupOrder) {
    if (materials.any((m) => m.group == g) && seen.add(g)) result.add(g);
  }
  for (final m in materials) {
    if (seen.add(m.group)) result.add(m.group);
  }
  return result;
}

List<MetalMaterial> gradesForGroup(String group) =>
    materials.where((m) => m.group == group).toList();

// ── Базовые марки (исходный короткий список для барабана) ─────────────────────
const Set<String> _basicGrades = {
  // Сталь
  '08пс', '09Г2С', '10', '10ХСНД', '17Г1С', '18ХГТ', '20', '20Х',
  '30ХГСА', '35', '40', '40Х', '45', '50', '60С2А', '65Г', '9ХС',
  'А12', 'Р18', 'Р6М5', 'Ст3кп', 'Ст3пс', 'Ст3сп', 'Ст5сп',
  'У10', 'У12', 'У8', 'ХВГ',
  // Нержавейка
  '03Х17Н14М3 (316L)', '08Х18Н10 (304)', '08Х18Н10Т (321)',
  '10Х17Н13М2Т (316)', '12Х13 (410)', '12Х17 (430)', '12Х18Н10Т',
  '12Х18Н9', '14Х17Н2 (431)', '15Х25Т (446)', '20Х13 (420)',
  '25Х13Н2', '30Х13', '40Х13',
  'AISI 201', 'AISI 304', 'AISI 316', 'AISI 316L', 'AISI 321', 'AISI 430',
  // Алюминий
  '6061', '6082', '7075 (В95)', 'А5', 'АД0', 'АД1', 'АД31', 'АК4',
  'АМг2', 'АМг3', 'АМг5', 'АМг6', 'АМц', 'В95', 'Д1', 'Д16', 'Д16Т',
  // Латунь
  'Л63', 'Л68', 'ЛО62-1', 'ЛС59-1',
  // Медь
  'М0', 'М00', 'М1', 'М2', 'М3',
  // Бронза
  'БрАМц9-2', 'БрБ2', 'БрКМц3-1', 'БрОФ10-1', 'БрОЦС4-4-2.5',
  // Вольфрам
  'ВА', 'ВАН',
  // Молибден
  'МВ', 'МЧ',
  // Никель
  'ВНМ3-2', 'НП1', 'НП2', 'Inconel 625',
  // Нихром
  'Х15Н60', 'Х20Н80',
  // Титан
  'ВТ1-0', 'ВТ1-00', 'ВТ6', 'ОТ4', 'Ti Grade 2', 'Ti Grade 5',
  // Цинк
  'Ц0', 'Ц1',
  // Цирконий
  'ЦрНб-1',
};

/// Базовые марки для группы (короткий список — для барабана)
List<MetalMaterial> basicGradesForGroup(String group) =>
    materials.where((m) => m.group == group && _basicGrades.contains(m.grade)).toList();

/// Все марки для группы (полный список — для sheet)
List<MetalMaterial> allGradesForGroup(String group) =>
    materials.where((m) => m.group == group).toList();
