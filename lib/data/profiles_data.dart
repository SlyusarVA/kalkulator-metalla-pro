import 'dart:math' as math;
import '../models/models.dart';
import 'gost_sizes.dart';

// Порядок сортамента — по объёму в остатках склада (от большего к меньшему).
// Позиций без остатков нет — все присутствуют, отсортированы по данным склада.

final List<MetalProfile> profiles = [
  // Труба кр. — наибольший объём на складе
  MetalProfile(name:'Труба кр.', gost:'ГОСТ 8732-78', iconAsset:'assets/icons/pipe.svg',
    params:[ProfileParam(key:'d',label:'Диаметр d',unit:'мм',defaultValue:57,drumValues:pipeDiameters),ProfileParam(key:'t',label:'Толщина стенки t',unit:'мм',defaultValue:3.5,drumValues:pipeWalls)],
    sectionArea:(v){final d=v['d']!,t=v['t']!;return math.pi/4*(d*d-(d-2*t)*(d-2*t));}),

  MetalProfile(name:'Лист', gost:'ГОСТ 19903-2015', iconAsset:'assets/icons/sheet.svg', isVolume:true,
    params:[ProfileParam(key:'a',label:'Длина листа',unit:'мм',defaultValue:1000,drumValues:sheetDims),ProfileParam(key:'b',label:'Ширина листа',unit:'мм',defaultValue:1000,drumValues:sheetDims),ProfileParam(key:'t',label:'Толщина t',unit:'мм',defaultValue:4,drumValues:sheetThickness)],
    sectionArea:(v)=>v['a']!*v['b']!*v['t']!),

  MetalProfile(name:'Круг', gost:'ГОСТ 2590-2006', iconAsset:'assets/icons/circle.svg',
    params:[ProfileParam(key:'d',label:'Диаметр',unit:'мм',defaultValue:20,drumValues:roundDiameters)],
    sectionArea:(v)=>math.pi/4*v['d']!*v['d']!),

  MetalProfile(name:'Арматура', gost:'ГОСТ 34028-2016', iconAsset:'assets/icons/armature.svg',
    params:[ProfileParam(key:'d',label:'Диаметр',unit:'мм',defaultValue:12,drumValues:armatDiameters)],
    sectionArea:(v)=>math.pi/4*v['d']!*v['d']!),

  MetalProfile(name:'Труба проф.', gost:'ГОСТ 8645-68', iconAsset:'assets/icons/pipe_prof.svg',
    params:[ProfileParam(key:'a',label:'Сторона A',unit:'мм',defaultValue:60,drumValues:profTubeRectSides),ProfileParam(key:'b',label:'Сторона B',unit:'мм',defaultValue:40,drumValues:profTubeRectSides),ProfileParam(key:'t',label:'Толщина t',unit:'мм',defaultValue:2,drumValues:profTubeWalls)],
    sectionArea:(v){final a=v['a']!,b=v['b']!,t=v['t']!;return a*b-(a-2*t)*(b-2*t);}),

  MetalProfile(name:'Уголок равн.', gost:'ГОСТ 8509-93', iconAsset:'assets/icons/corner.svg',
    params:[ProfileParam(key:'b',label:'Ширина полки a',unit:'мм',defaultValue:50,drumValues:equalAngleSides),ProfileParam(key:'t',label:'Толщина t',unit:'мм',defaultValue:5,drumValues:angleTh)],
    sectionArea:(v)=>v['t']!*(2*v['b']!-v['t']!)),

  MetalProfile(name:'Балка', gost:'ГОСТ 8239-89', iconAsset:'assets/icons/balk.svg',
    params:[ProfileParam(key:'h',label:'Высота H',unit:'мм',defaultValue:100),ProfileParam(key:'b',label:'Ширина B',unit:'мм',defaultValue:55),ProfileParam(key:'tw',label:'Толщина стенки s',unit:'мм',defaultValue:4.5),ProfileParam(key:'tf',label:'Толщина полки t',unit:'мм',defaultValue:7.2)],
    sectionArea:(v)=>v['tw']!*(v['h']!-2*v['tf']!)+2*v['b']!*v['tf']!),

  MetalProfile(name:'Швеллер', gost:'ГОСТ 8240-97', iconAsset:'assets/icons/channel.svg',
    params:[ProfileParam(key:'h',label:'Высота H',unit:'мм',defaultValue:100),ProfileParam(key:'b',label:'Ширина B',unit:'мм',defaultValue:46),ProfileParam(key:'tw',label:'Толщина стенки s',unit:'мм',defaultValue:4.5),ProfileParam(key:'tf',label:'Толщина полки t',unit:'мм',defaultValue:7.2)],
    sectionArea:(v)=>v['tw']!*v['h']!+2*v['b']!*v['tf']!-2*v['tf']!*v['tw']!),

  MetalProfile(name:'Полоса', gost:'ГОСТ 103-2006', iconAsset:'assets/icons/strip.svg',
    params:[ProfileParam(key:'b',label:'Ширина a',unit:'мм',defaultValue:40,drumValues:stripWidths),ProfileParam(key:'t',label:'Толщина t',unit:'мм',defaultValue:4,drumValues:stripThickness)],
    sectionArea:(v)=>v['b']!*v['t']!),

  MetalProfile(name:'Квадрат', gost:'ГОСТ 2591-2006', iconAsset:'assets/icons/square.svg',
    params:[ProfileParam(key:'a',label:'Сторона a',unit:'мм',defaultValue:20,drumValues:squareSides)],
    sectionArea:(v)=>v['a']!*v['a']!),

  MetalProfile(name:'Шестигранник', gost:'ГОСТ 2879-2006', iconAsset:'assets/icons/hexahedron.svg',
    params:[ProfileParam(key:'d',label:'Размер под ключ',unit:'мм',defaultValue:24,drumValues:hexSizes)],
    sectionArea:(v)=>0.866025*v['d']!*v['d']!),

  MetalProfile(name:'Уголок неравн.', gost:'ГОСТ 8510-86', iconAsset:'assets/icons/corner_unequal.svg',
    params:[ProfileParam(key:'b1',label:'Полка a',unit:'мм',defaultValue:63,drumValues:unequalAngle1),ProfileParam(key:'b2',label:'Полка b',unit:'мм',defaultValue:40,drumValues:unequalAngle2),ProfileParam(key:'t',label:'Толщина t',unit:'мм',defaultValue:5,drumValues:angleTh)],
    sectionArea:(v)=>v['t']!*(v['b1']!+v['b2']!-v['t']!)),

  MetalProfile(name:'Пруток', gost:'ГОСТ 2060-2006', iconAsset:'assets/icons/rod.svg',
    params:[ProfileParam(key:'d',label:'Диаметр',unit:'мм',defaultValue:25,drumValues:rodDiameters)],
    sectionArea:(v)=>math.pi/4*v['d']!*v['d']!),

  MetalProfile(name:'Плита', gost:'ГОСТ 17232-99', iconAsset:'assets/icons/plate.svg', isVolume:true,
    params:[ProfileParam(key:'a',label:'Длина',unit:'мм',defaultValue:1000,drumValues:sheetDims),ProfileParam(key:'b',label:'Ширина',unit:'мм',defaultValue:1000,drumValues:sheetDims),ProfileParam(key:'t',label:'Толщина t',unit:'мм',defaultValue:20,drumValues:sheetThickness)],
    sectionArea:(v)=>v['a']!*v['b']!*v['t']!),

  MetalProfile(name:'Лента', gost:'ГОСТ 503-81', iconAsset:'assets/icons/strip.svg',
    params:[ProfileParam(key:'b',label:'Ширина a',unit:'мм',defaultValue:20,drumValues:stripWidths),ProfileParam(key:'t',label:'Толщина t',unit:'мм',defaultValue:1.5,drumValues:stripThickness)],
    sectionArea:(v)=>v['b']!*v['t']!),

  MetalProfile(name:'Проволока', gost:'ГОСТ 792-67', iconAsset:'assets/icons/wire.svg',
    params:[ProfileParam(key:'d',label:'Диаметр',unit:'мм',defaultValue:1.0,drumValues:wireDiameters)],
    sectionArea:(v)=>math.pi/4*v['d']!*v['d']!),

  MetalProfile(name:'Рельс', gost:'ГОСТ Р 51685-2013', iconAsset:'assets/icons/rail.svg',
    params:[ProfileParam(key:'w',label:'Погонный вес',unit:'кг/м',defaultValue:43)],
    sectionArea:(v)=>v['w']!*1e6/7850),

  MetalProfile(name:'Шпунт', gost:'ГОСТ 4781-85', iconAsset:'assets/icons/shpunt.svg',
    params:[ProfileParam(key:'h',label:'Высота H',unit:'мм',defaultValue:400),ProfileParam(key:'b',label:'Ширина B',unit:'мм',defaultValue:150),ProfileParam(key:'t',label:'Толщина t',unit:'мм',defaultValue:9.5)],
    sectionArea:(v)=>v['b']!*v['t']!+2*(v['h']!/2)*v['t']!),
];
