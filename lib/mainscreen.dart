import 'package:flutter/material.dart';
import 'constants.dart';
import 'inference.dart';
import 'painter.dart';


class mainScreen extends StatefulWidget{
  @override
  _mainScreenState createState() => _mainScreenState();
  }

class _mainScreenState extends State<mainScreen>{
  //Variables requeridas
  AppBrain inferencia = AppBrain(); //Clase que carga el modelo
  List<Offset> points = List(); //Puntos de canvas
  var number;
  var percentage;

  @override //Porque se va ainvocar un initState
  void initState(){
    super.initState();
    inferencia.loadModel(); //Modelo de tflite (carga)
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Detect number"),
          backgroundColor: Colors.deepOrangeAccent,
        ),
        body: Container( //SE PUEDE REMOVER
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(height: 50.0,),
              Container(
                decoration: new BoxDecoration(
                  border: new Border.all(
                    width: 4.0,
                    color: Colors.deepOrangeAccent,
                  ),
                ),
                child: Builder( //Detector de Gestos en Pantalla //Child from the container
                  builder: (BuildContext context) {
                    return GestureDetector( //Revisar clase
                      onPanUpdate: (details) {
                        setState(() {
                          RenderBox renderBox = context.findRenderObject();
                          points.add(
                              renderBox.globalToLocal(details.globalPosition));
                        });
                      },
                      onPanStart: (details) {
                        setState(() {
                          RenderBox renderBox = context.findRenderObject();
                          points.add(
                              renderBox.globalToLocal(details.globalPosition));
                        });
                      },
                      onPanEnd: (details) async { //Modificar a async
                        //setState(() async {
                        points.add(null); //PINTAR
                        List predictions = await inferencia.processCanvasPoints(
                            points); //Se pasan los puntos para edicion
                        number=("${predictions[0]["label"]}").toString();
                        percentage=("${predictions[0]["confidence"]}").toString();
                        //print("La red predice: ");
                        //print(predictions); //Aqui se obtienen las predcciones
                        setState(() {});
                        //});
                      },
                      child: ClipRect( //By default, ClipRect prevents its child from painting outside its bounds, but the size and location of the clip rect can be customized using a custom clipper.
                        child: CustomPaint( //A widget that provides a canvas on which to draw during the paint phase.
                          size: Size(kCanvasSize, kCanvasSize),
                          //En la clase constants
                          painter: Painter( //Clase Propia usamos un Painter Personalizado
                            offsetPoints: points, //Puntos recolectados del método de arriba
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              number==null ? Text(""): Text(number),
              percentage==null ? Text(""):Text(percentage),
              Expanded(
                //flex: 1,
                child: Container(
                  padding: EdgeInsets.all(16),
                  //color: Colors.blue,
                  alignment: Alignment.center,
                  child: MaterialButton(
                    child: Text("Delete"),
                    color: Colors.deepOrangeAccent,
                    onPressed: () {
                      points.clear();
                    },
                  ),
                ),
              ),
            ],
          ),
        ));
  }

}