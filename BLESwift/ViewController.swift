import CoreBluetooth
import UIKit
import CoreLocation

class ViewController: UIViewController {
    var centralManager: CBCentralManager?
    var peripherals = Array<CBPeripheral>()
    let firstBeacon = NSUUID.init(uuidString: "BF0699BE-02D2-0D58-C34A-F1A172FBF6A3") as UUID?
    let secondBeacon = NSUUID.init(uuidString: "D8EA97E4-7B3C-79DE-A9ED-DDC984C087D3") as UUID?
    let thirdBeacon = NSUUID.init(uuidString: "E772C3AD-904B-A0FA-B70A-AF9812764BD7") as UUID?
    var firstBeaconDistance:Float = 0.0
    var secondBeaconDistance:Float = 0.0
    var thirdBeaconDistance:Float = 0.0
    var MP = -67
    var numi = 20
    var fraction:Float = 0.0
    var numarator:Int = 0
    var pulsationLayer: CAShapeLayer!
    var beaconB = CGPoint(x: 0.0, y: 0.0)
    var beaconD = CGPoint(x: 375.0, y: 670.0)
    var beaconE = CGPoint(x: 0, y: 670.0)
    var currentLocation = CGPoint(x: 50.0, y: 50.0)
    var doorLabel: UILabel!
    var locationManager:CLLocationManager!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 21/255, green: 22/255, blue: 33/255, alpha: 1)
        doorLabel = UILabel()
        doorLabel.text = "DOOR"
        doorLabel.center = CGPoint(x: 20, y: 25)
        doorLabel.sizeToFit()
        doorLabel.textColor = UIColor.white
        view.addSubview(doorLabel)
        
        //Initialise CoreBluetooth Central Manager
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
        addUserOnTheScreen()
    }
}

extension ViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if (central.state == .poweredOn){
            self.centralManager?.scanForPeripherals(withServices: nil, options: nil)
        }
        else {
            // do something like alert the user that ble is not on
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //if(peripheral.name=="RadioLand iBeacon"){
        if(peripheral.name==Optional("Radioland iBeacon")){
            switch(peripheral.identifier){
            case firstBeacon: firstBeaconDistance = calculateDistance(RSSI: RSSI)
            break;
            case secondBeacon: secondBeaconDistance    = calculateDistance(RSSI: RSSI)
            break;
            case thirdBeacon: thirdBeaconDistance = calculateDistance(RSSI: RSSI)
            break;
            default:
                firstBeaconDistance = calculateDistance(RSSI: RSSI)
            }
            peripherals.append(peripheral)
            print(peripheral.identifier)
            print(calculateDistance(RSSI: RSSI))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion){
        guard let discoverBeaconProximity = beacons.first?.proximity else {print("couldn't find the beacon"); return;}
        
        print("yeeeeeeeeeees")
    }
    
    func calculateDistance(RSSI: NSNumber)->Float{
        
        numarator = self.MP-Int(RSSI)
        self.fraction = Float(numarator)/Float(self.numi)
        return pow(10,fraction)
    }
    
    func addUserOnTheScreen(){
        let shapeLayer = CAShapeLayer()
        
        //let center = view.center
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 10, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
       // shapeLayer.path = circularPath.cgPath;
       
        
        pulsationLayer = CAShapeLayer()
        pulsationLayer.path = circularPath.cgPath
        pulsationLayer.strokeColor = UIColor.clear.cgColor
        pulsationLayer.lineWidth = 10
        pulsationLayer.fillColor = UIColor.yellow.cgColor
        pulsationLayer.lineCap = kCALineCapRound
        pulsationLayer.position = self.currentLocation
        
        animatePulsatingLayer()
        view.layer.addSublayer(pulsationLayer)
    }
    
    private func animatePulsatingLayer(){
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = 1.6
        animation.duration = 0.9
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        pulsationLayer.add(animation, forKey: "pulsing")
    }
    
    private func getCurrentLocation()->CGPoint{
        var W = Double(pow(firstBeaconDistance,2)) - Double(pow(secondBeaconDistance,2)) - Double(pow(beaconB.x,2)) - Double(pow(beaconB.y,2)) - Double(pow(beaconD.x, 2)) - Double(pow(beaconD.y,2))
        var Z = Double(pow(thirdBeaconDistance,2)) - Double(pow(thirdBeaconDistance,2)) - Double(pow(beaconE.x,2)) - Double(pow(beaconE.y,2)) - Double(pow(beaconD.x, 2)) - Double(pow(beaconD.y,2))
        var numarator1 = W*Double(beaconE.y - beaconD.y) - Z*Double(beaconD.y - beaconB.y)
        var numitor1 = 2 * Double((beaconD.x-beaconB.x)*(beaconE.y-beaconD.y) - (beaconE.x - beaconD.x)*(beaconD.y - beaconB.y))
        var x =  numarator1 / numitor1
        //var ynumarator = (W - 2.0*x*(beaconD.x-beaconB.x))
        //var ynumitor = (2*(beaconD.y - beaconB.y))
       // var y = ynumarator/ynumitor
       // error mitigation
       //var y2 = (Z - 2*x*(beaconE.x-beaconD.x)) / (2*(beaconE.y-beaconD.y))
        
       // y = (y+y2)/2;
        
        return CGPoint(x: 0, y: 0)//CGPoint(x,y)
        
    }
    
}



extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        
        let peripheral = peripherals[indexPath.row]
        cell.textLabel?.text = peripheral.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
}
