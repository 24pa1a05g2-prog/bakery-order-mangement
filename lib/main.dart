import 'package:flutter/material.dart';

void main() => runApp(const BakeryApp());

class BakeryApp extends StatelessWidget {
  const BakeryApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Crumb & Co. Bakery',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF985638)), scaffoldBackgroundColor: const Color(0xFFFFFBF7)),
    home: const BakeryHome(),
  );
}

enum Status { pending, baking, ready, completed }
class Order {
  Order(this.id, this.customer, this.product, this.qty, this.total, this.created, [this.status = Status.pending]);
  final int id, qty; final String customer, product; final double total; final DateTime created; Status status;
}

class BakeryHome extends StatefulWidget {
  const BakeryHome({super.key});
  @override State<BakeryHome> createState() => _BakeryHomeState();
}
class _BakeryHomeState extends State<BakeryHome> {
  final products = <String,double>{'Sourdough Bread':160,'Butter Croissant':90,'Chocolate Cake':650,'Blueberry Muffin':110,'Cinnamon Roll':130,'Vanilla Cupcake':85};
  final orders = <Order>[
    Order(1048,'Ananya Rao','Chocolate Cake',1,650,DateTime.now().subtract(const Duration(minutes: 8)),Status.baking),
    Order(1047,'Rahul Kumar','Butter Croissant',4,360,DateTime.now().subtract(const Duration(minutes: 18))),
    Order(1046,'Priya Sharma','Sourdough Bread',2,320,DateTime.now().subtract(const Duration(minutes: 32)),Status.ready),
    Order(1045,'Arjun Reddy','Blueberry Muffin',3,330,DateTime.now().subtract(const Duration(hours: 1)),Status.completed),
  ];
  final customer = TextEditingController(), quantity = TextEditingController(text:'1'), searchBox = TextEditingController();
  String chosenProduct = 'Sourdough Bread', filter = 'All', search = '';
  int nav = 0;
  String label(Status s) => switch(s){Status.pending=>'Pending',Status.baking=>'Baking',Status.ready=>'Ready',Status.completed=>'Completed'};
  Color tone(Status s) => switch(s){Status.pending=>const Color(0xFFB7791F),Status.baking=>const Color(0xFF5476A5),Status.ready=>const Color(0xFF27845B),Status.completed=>const Color(0xFF68736D)};
  String rupees(num n) => '₹${n.toStringAsFixed(0)}';
  int count(Status s)=>orders.where((o)=>o.status==s).length;
  double get sales=>orders.where((o)=>o.status==Status.completed).fold(0,(v,o)=>v+o.total);

  Future<void> newOrder() async {
    customer.clear(); quantity.text='1'; chosenProduct=products.keys.first;
    final result=await showDialog<bool>(context:context,builder:(ctx)=>StatefulBuilder(builder:(ctx,refresh)=>AlertDialog(
      title:const Text('Create new order'),
      content:SizedBox(width:360,child:Column(mainAxisSize:MainAxisSize.min,children:[
        TextField(controller:customer,decoration:const InputDecoration(labelText:'Customer name',prefixIcon:Icon(Icons.person_outline))),
        const SizedBox(height:12),
        DropdownButtonFormField<String>(value:chosenProduct,decoration:const InputDecoration(labelText:'Bakery item'),items:products.keys.map((p)=>DropdownMenuItem(value:p,child:Text(p))).toList(),onChanged:(v)=>refresh(()=>chosenProduct=v!)),
        const SizedBox(height:12),
        TextField(controller:quantity,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Quantity',prefixIcon:Icon(Icons.shopping_basket_outlined))),
      ])),
      actions:[TextButton(onPressed:()=>Navigator.pop(ctx,false),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(ctx,true),child:const Text('Add order'))],
    )));
    final q=int.tryParse(quantity.text)??0;
    if(result==true && customer.text.trim().isNotEmpty && q>0) setState(()=>orders.insert(0,Order(orders.first.id+1,customer.text.trim(),chosenProduct,q,products[chosenProduct]!*q,DateTime.now())));
  }
  @override void dispose(){customer.dispose();quantity.dispose();searchBox.dispose();super.dispose();}

  @override Widget build(BuildContext context){
    final compact=MediaQuery.sizeOf(context).width<760;
    final visible=orders.where((o)=>(filter=='All'||label(o.status)==filter)&&('${o.customer} ${o.product} #${o.id}'.toLowerCase().contains(search))).toList();
    return Scaffold(
      appBar:AppBar(title:Row(children:[Container(padding:const EdgeInsets.all(9),decoration:BoxDecoration(color:const Color(0xFF985638),borderRadius:BorderRadius.circular(12)),child:const Icon(Icons.bakery_dining,color:Colors.white)),const SizedBox(width:10),const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('crumb & co.',style:TextStyle(fontWeight:FontWeight.w800)),Text('BAKERY STUDIO',style:TextStyle(fontSize:9,letterSpacing:2,color:Color(0xFF985638)))])]),actions:[const Center(child:Text('Good morning ☀️')),const SizedBox(width:18),const CircleAvatar(child:Text('B')),const SizedBox(width:16)]),
      body:Row(children:[
        if(!compact) NavigationRail(selectedIndex:nav,onDestinationSelected:(v)=>setState(()=>nav=v),labelType:NavigationRailLabelType.all,destinations:const [NavigationRailDestination(icon:Icon(Icons.dashboard_outlined),label:Text('Overview')),NavigationRailDestination(icon:Icon(Icons.receipt_long_outlined),label:Text('Orders')),NavigationRailDestination(icon:Icon(Icons.cake_outlined),label:Text('Menu'))]),
        Expanded(child:SingleChildScrollView(padding:EdgeInsets.all(compact?16:30),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Row(children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(nav==2?'Bakery menu':nav==1?'Order management':'Dashboard',style:const TextStyle(fontSize:28,fontWeight:FontWeight.w800)),const SizedBox(height:5),const Text('Here’s what’s happening in your bakery today.',style:TextStyle(color:Color(0xFF88786E)))])),if(!compact) FilledButton.icon(onPressed:newOrder,icon:const Icon(Icons.add),label:const Text('New order'))]),
          if(compact) ...[const SizedBox(height:16),SizedBox(width:double.infinity,child:FilledButton.icon(onPressed:newOrder,icon:const Icon(Icons.add),label:const Text('New order')))],
          const SizedBox(height:24),
          GridView.count(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),crossAxisCount:compact?2:4,crossAxisSpacing:12,mainAxisSpacing:12,childAspectRatio:1.7,children:[
            stat('Total orders','${orders.length}',Icons.receipt_long,'Today'),
            stat('In the kitchen','${count(Status.pending)+count(Status.baking)}',Icons.local_fire_department,'Being prepared'),
            stat('Ready to collect','${count(Status.ready)}',Icons.shopping_bag,'Awaiting pickup'),
            stat('Sales completed',rupees(sales),Icons.payments,'Completed orders'),
          ]),
          const SizedBox(height:28),
          if(nav==2) menu(compact) else ...[
            Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[const Text('Recent orders',style:TextStyle(fontSize:20,fontWeight:FontWeight.w800)),Text('${orders.length} orders',style:const TextStyle(color:Color(0xFF88786E)))]),
            const SizedBox(height:14),
            TextField(controller:searchBox,onChanged:(v)=>setState(()=>search=v.toLowerCase()),decoration:const InputDecoration(hintText:'Search customer, item or order ID...',prefixIcon:Icon(Icons.search))),
            const SizedBox(height:12),
            Wrap(spacing:8,children:['All','Pending','Baking','Ready','Completed'].map((s)=>ChoiceChip(label:Text(s),selected:filter==s,onSelected:(_)=>setState(()=>filter=s))).toList()),
            const SizedBox(height:12),
            Card(child:Padding(padding:const EdgeInsets.all(8),child:Column(children:visible.isEmpty?[const Padding(padding:EdgeInsets.all(24),child:Text('No matching orders'))]:visible.map((o)=>orderRow(o,compact)).toList()))),
          ],
          const SizedBox(height:20),
          Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:const Color(0xFFF5EAE1),borderRadius:BorderRadius.circular(16)),child:const Row(children:[Icon(Icons.lightbulb_outline,color:Color(0xFF985638)),SizedBox(width:10),Expanded(child:Text('Keep order statuses updated so customers know when their treats are ready.',style:TextStyle(color:Color(0xFF684A3D))))])),
        ]))),
      ]),
      bottomNavigationBar:compact?NavigationBar(selectedIndex:nav,onDestinationSelected:(v)=>setState(()=>nav=v),destinations:const [NavigationDestination(icon:Icon(Icons.dashboard_outlined),label:'Overview'),NavigationDestination(icon:Icon(Icons.receipt_long_outlined),label:'Orders'),NavigationDestination(icon:Icon(Icons.cake_outlined),label:'Menu')]):null,
    );
  }
  Widget stat(String title,String value,IconData icon,String note)=>Card(child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Icon(icon,color:const Color(0xFF985638)),Text(value,style:const TextStyle(fontSize:24,fontWeight:FontWeight.w800)),Text(title,style:const TextStyle(fontWeight:FontWeight.w600,fontSize:12)),Text(note,style:const TextStyle(color:Color(0xFF96877E),fontSize:10))])));
  Widget orderRow(Order o,bool compact)=>Padding(padding:const EdgeInsets.symmetric(horizontal:8,vertical:10),child:Row(children:[
    const CircleAvatar(backgroundColor:Color(0xFFF6EDE6),child:Icon(Icons.bakery_dining,color:Color(0xFF985638))),
    const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(o.customer,style:const TextStyle(fontWeight:FontWeight.bold)),Text('#${o.id} · ${o.qty} × ${o.product}',maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:12,color:Color(0xFF88786E)))])),
    if(!compact) Padding(padding:const EdgeInsets.only(right:12),child:Text(rupees(o.total),style:const TextStyle(fontWeight:FontWeight.bold))),
    PopupMenuButton<Status>(onSelected:(s)=>setState(()=>o.status=s),itemBuilder:(_)=>Status.values.map((s)=>PopupMenuItem(value:s,child:Text('Mark ${label(s)}'))).toList(),child:Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:7),decoration:BoxDecoration(color:tone(o.status).withOpacity(.12),borderRadius:BorderRadius.circular(20)),child:Text(label(o.status),style:TextStyle(color:tone(o.status),fontSize:11,fontWeight:FontWeight.bold)))),
  ]));
  Widget menu(bool compact)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Today’s favourites',style:TextStyle(fontSize:20,fontWeight:FontWeight.w800)),const SizedBox(height:12),GridView.count(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),crossAxisCount:compact?2:3,crossAxisSpacing:12,mainAxisSpacing:12,childAspectRatio:1.6,children:products.entries.map((e)=>Card(child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.center,children:[const Icon(Icons.cake_outlined,color:Color(0xFF985638),size:28),const SizedBox(height:8),Text(e.key,style:const TextStyle(fontWeight:FontWeight.bold)),Text(rupees(e.value),style:const TextStyle(color:Color(0xFF985638),fontWeight:FontWeight.w800))])))).toList())]);
}
