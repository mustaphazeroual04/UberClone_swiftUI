//
//  ContentView.swift
//  UberClone
//
//  Created by MUSTAPHA on 27/11/2023.
//

import SwiftUI
import MapKit
import CoreLocation

struct ContentView: View {
    var body: some View {
        Home()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct Home : View {


    @State var map = MKMapView()
    @State var manager = CLLocationManager()
    @State var alert : Bool = false
    @State var source : CLLocationCoordinate2D!
    @State var destination : CLLocationCoordinate2D!
    
    @State var region = MKCoordinateRegion(
            center: .init(latitude: 37.334_900,longitude: -122.009_020),
            span: .init(latitudeDelta: 0.2, longitudeDelta: 0.2)
        )
    
    var body: some View{
        ZStack{
            VStack(spacing: 0){
                HStack{
                    Text("Pick a Location")
                        .font(.title)
                    
                    Spacer()
                }
                .padding()
                .padding(.top, (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets.top)
                .background(Color.white)
                
                MapView(map: self.$map, manager: self.$manager, alert: self.$alert, source: self.$source, destination: self.$destination)
                    .onAppear {
                        self.manager.requestWhenInUseAuthorization()
                    }
         //Map(coordinateRegion: $region)
                    //.edgesIgnoringSafeArea(.all)
            }
            .edgesIgnoringSafeArea(.all)
            .alert(isPresented: self.$alert) { () -> Alert in
                Alert(title: Text("Error"), message: Text("Please Enable Location In settings !!!"), dismissButton: .destructive(Text("Ok")))
                
            }
        }
    }
}


struct MapView : UIViewRepresentable {
    
    func makeCoordinator() -> Coordinator {
        return MapView.Coordinator(parent1: self)
    }
    
    
    @Binding var map : MKMapView
    @Binding var manager : CLLocationManager
    @Binding var alert : Bool
    @Binding var source : CLLocationCoordinate2D!
    @Binding var destination : CLLocationCoordinate2D!

    func makeUIView(context: Context) ->  MKMapView {
        map.delegate = context.coordinator
        manager.delegate = context.coordinator
        map.showsUserLocation = true
        let gesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.tap(ges:)))
        map.addGestureRecognizer(gesture)
        return map
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
    
    }
    
    class Coordinator : NSObject,MKMapViewDelegate,CLLocationManagerDelegate {
        
        var parent : MapView
        
        init(parent1 : MapView) {
            parent = parent1
        }
        
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
            if status == .denied{
                
                self.parent.alert.toggle()
            } else {
                self.parent.manager.startUpdatingLocation()
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            
            let region = MKCoordinateRegion(center: locations.last!.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
            self.parent.source =   locations.last!.coordinate
            
            self.parent.map.region = region
        }
        
        @objc func tap(ges: UITapGestureRecognizer){
            let location = ges.location(in: self.parent.map)
            let mplocation = self.parent.map.convert(location, toCoordinateFrom: self.parent.map)
            
            let point = MKPointAnnotation()
            point.title = "Marked"
            point.subtitle = "Destination"
            
            point.coordinate = mplocation
            self.parent.map.removeAnnotations(self.parent.map.annotations)
            self.parent.map.addAnnotation(point)
        }
    }
}
