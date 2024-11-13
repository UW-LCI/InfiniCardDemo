import 'package:infinicard_v1/functions/helpers.dart';
import 'package:infinicard_v1/models/draw_actions.dart';
import 'package:infinicard_v1/models/draw_actions/box_action.dart';
import 'package:infinicard_v1/objects/ICAppBar.dart';
import 'package:infinicard_v1/objects/ICButtonStyle.dart';
import 'package:infinicard_v1/objects/ICColor.dart';
import 'package:infinicard_v1/objects/ICColumn.dart';
import 'package:infinicard_v1/objects/ICIcon.dart';
import 'package:infinicard_v1/objects/ICIconButton.dart';
import 'package:infinicard_v1/objects/ICImage.dart';
import 'package:infinicard_v1/objects/ICObject.dart';
import 'package:infinicard_v1/objects/ICRow.dart';
import 'package:infinicard_v1/objects/ICText.dart';
import 'package:infinicard_v1/objects/ICTextButton.dart';
import 'package:infinicard_v1/objects/ICUndefined.dart';
import 'package:xml/xml.dart';

String compileDrawing(List<DrawAction> canvasActions) {
  XmlElement drawingXML = XmlElement(XmlName("root"));
  XmlElement ui = XmlElement(XmlName("ui"), [], [XmlText("")]);

  for (DrawAction action in canvasActions) {
    if (action is BoxAction) {
      if (action.active) {
        ICObject element = compileElement(action, canvasActions, ui);
        ui.children.add(element.toXml(verbose: true));
      }
    }
  }
  drawingXML.children.add(ui);
  return drawingXML.toXmlString(pretty: true);
}

ICObject compileElement(
    BoxAction action, List<DrawAction> canvasActions, XmlElement ui) {
  ICObject element = ICUndefined();
  switch (action.elementName) {
    case "textButton":
      ICTextButton actionElement = action.element as ICTextButton;
      actionElement.setSize(heightArg: action.rect.height, widthArg: action.rect.width);
      actionElement.setLocation(leftArg: action.rect.topLeft.dx, topArg: action.rect.topLeft.dy);
      element = actionElement;
      break;
    case "text":
      ICText actionElement = action.element as ICText;
      actionElement.setSize(heightArg: action.rect.height, widthArg: action.rect.width);
      actionElement.setLocation(leftArg: action.rect.topLeft.dx, topArg: action.rect.topLeft.dy);
      element = actionElement;
      break;
    case "image":
      ICImage actionElement = action.element as ICImage;
      actionElement.setSize(heightArg: action.rect.height, widthArg: action.rect.width);
      actionElement.setLocation(leftArg: action.rect.topLeft.dx, topArg: action.rect.topLeft.dy);
      element = actionElement;
      break;
    case "row":
      ICRow row = action.element as ICRow;
      List<BoxAction> childrenActions = getChildren(action, canvasActions);
      List<ICObject> childrenElements = [];
      for (BoxAction child in childrenActions) {
        childrenElements.add(compileElement(child, canvasActions, ui));
        child.active = false;
        List<XmlElement> existing = ui
            .findAllElements(child.elementName)
            .where((tag) => tag.getAttribute('id') == child.uniqueID.toString())
            .toList();
        for (XmlElement element in existing) {
          element.remove();
        }
      }
      row.children = childrenElements;
      element = row;
      break;
    case "column":
      ICColumn column = action.element as ICColumn;
      List<BoxAction> childrenActions = getChildren(action, canvasActions);
      List<ICObject> childrenElements = [];
      for (BoxAction child in childrenActions) {
        childrenElements.add(compileElement(child, canvasActions, ui));
        child.active = false;
        List<XmlElement> existing = ui
            .findAllElements(child.elementName)
            .where((tag) => tag.getAttribute('id') == child.uniqueID.toString())
            .toList();
        for (XmlElement element in existing) {
          element.remove();
        }
      }
      column.children = childrenElements;
      element = column;
      break;
    case "iconButton":
      ICIconButton actionElement = action.element as ICIconButton;
      actionElement.setSize(heightArg: action.rect.height, widthArg: action.rect.width);
      actionElement.setLocation(leftArg: action.rect.topLeft.dx, topArg: action.rect.topLeft.dy);
      element = actionElement;
      break;
    case "icon":
      ICIcon actionElement = action.element as ICIcon;
      actionElement.setSize(heightArg: action.rect.height, widthArg: action.rect.width);
      actionElement.setLocation(leftArg: action.rect.topLeft.dx, topArg: action.rect.topLeft.dy);
      element = actionElement;
      break;
    case "bar":
      List<BoxAction> childrenWidgets = getChildren(action, canvasActions);
      List<BoxAction> actionBoxes = [];
      List<ICObject> actions = [];
      List<ICObject> leadingElements = [];
      ICObject? leadingWidget;
      ICObject? title;
      for (BoxAction child in childrenWidgets) {
        if(child.elementName == 'iconButton' || child.elementName == 'textButton'){
          actionBoxes.add(child);
        } else if(child.elementName == 'text'){
          title = compileElement(child, canvasActions, ui);
        } else {
          leadingElements.add(compileElement(child, canvasActions, ui));
        }
        child.active = false;
        List<XmlElement> existing = ui
            .findAllElements(child.elementName)
            .where((tag) => tag.getAttribute('id') == child.uniqueID.toString())
            .toList();
        for (XmlElement element in existing) {
          element.remove();
        }
      }
      actionBoxes.sort((a, b) => a.rect.left.compareTo(b.rect.left));
      for(BoxAction action in actionBoxes){
        actions.add(compileElement(action, canvasActions, ui));
      }
      if(leadingElements.length > 1){
        leadingWidget = ICRow(leadingElements);
      } else if(leadingElements.length == 1){
        leadingWidget = leadingElements[0];
      }
      ICAppBar bar = action.element as ICAppBar;
      if(actions.isNotEmpty){
        bar.setActions(actions);
      }
      if(leadingWidget != null){
        bar.setLeading(leadingWidget);
      }
      if(title != null){
        bar.setTitle(title);
      }
      element = bar;
      break;
    default:
      element = ICUndefined();
  }
  return element;
}

ICObject initElement(
    BoxAction action, List<DrawAction> canvasActions) {
  ICObject element = ICUndefined();
  switch (action.elementName) {
    case "textButton":
      ICButtonStyle style = ICButtonStyle();
      style.setBackgroundColor(color: ICColor("white"));
      ICTextButton textButton = ICTextButton();
      textButton.id = action.uniqueID;
      textButton.setSize(
          heightArg: action.rect.height, widthArg: action.rect.width);
      textButton.setLocation(
          leftArg: action.rect.topLeft.dx, topArg: action.rect.topLeft.dy);
      textButton.setStyle(style);
      element = textButton;
      break;
    case "text":
      ICText text = ICText("Text");
      text.id = action.uniqueID;
      text.setSize(heightArg: action.rect.height, widthArg: action.rect.width);
      text.setLocation(
          leftArg: action.rect.topLeft.dx, topArg: action.rect.topLeft.dy);
      element = text;
      break;
    case "image":
      ICImage image = ICImage("upload.png");
      image.id = action.uniqueID;
      image.setSize(heightArg: action.rect.height, widthArg: action.rect.width);
      image.setLocation(
          leftArg: action.rect.topLeft.dx, topArg: action.rect.topLeft.dy);
      element = image;
      break;
    case "row":
      List<ICObject> childrenElements = [];
      ICRow row = ICRow(childrenElements);
      row.id = action.uniqueID;
      row.setSize(heightArg: action.rect.height, widthArg: action.rect.width);
      row.setLocation(
          leftArg: action.rect.topLeft.dx, topArg: action.rect.topLeft.dy);
      element = row;
      break;
    case "column":
      List<ICObject> childrenElements = [];
      ICColumn column = ICColumn(childrenElements);
      column.id = action.uniqueID;
      column.setSize(heightArg: action.rect.height, widthArg: action.rect.width);
      column.setLocation(
          leftArg: action.rect.topLeft.dx, topArg: action.rect.topLeft.dy);
      element = column;
      break;
    case "iconButton":
      ICButtonStyle style = ICButtonStyle();
      style.setBackgroundColor(color: ICColor("white"));
      ICIconButton iconButton = ICIconButton();
      iconButton.id = action.uniqueID;
      iconButton.setSize(
          heightArg: action.rect.height, widthArg: action.rect.width);
      iconButton.setIconSize(action.rect.height / 2);
      iconButton.setLocation(
          leftArg: action.rect.topLeft.dx, topArg: action.rect.topLeft.dy);
      iconButton.setStyle(style);
      element = iconButton;
      break;
    case "icon":
      ICIcon icon = ICIcon();
      icon.id = action.uniqueID;
      icon.setSize(heightArg: action.rect.height, widthArg: action.rect.width);
      icon.setIconSize(action.rect.height);
      icon.setLocation(
          leftArg: action.rect.topLeft.dx, topArg: action.rect.topLeft.dy);
      element = icon;
      break;
    case "bar":
      ICAppBar bar = ICAppBar();
      bar.id = action.uniqueID;
      bar.setSize(heightArg: action.rect.height, widthArg: action.rect.width);
      bar.setToolbarHeight(action.rect.height);
      bar.setLocation(
          leftArg: action.rect.topLeft.dx, topArg: action.rect.topLeft.dy);
      bar.setBackgroundColor(ICColor("white"));

      element = bar;
      break;
    default:
      element = ICUndefined();
  }
  return element;
}

List<BoxAction> getChildren(BoxAction parent, List<DrawAction> canvasActions) {
  List<BoxAction> children = [];
  List<BoxAction> possibleChildren = [];

  for (DrawAction action in canvasActions) {
    if (action is BoxAction) {
      if (action!=parent && contained(parent, action)) {
        possibleChildren.add(action);
      }
    }
  }
  for(BoxAction possibleChild in possibleChildren){
    bool notContained = true;
    for(BoxAction possibleParent in possibleChildren){
      if(contained(possibleParent, possibleChild)){
        if(possibleParent!=possibleChild){
          notContained = false;
        } 
      } 
    }
    if(notContained){
      children.add(possibleChild);
    }
  }
  return children;
}


