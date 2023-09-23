class ListItem {
  String item;
  bool checked;

  ListItem(this.item, this.checked);

  @override
  String toString(){
    return "$item is $checked";
  }
}