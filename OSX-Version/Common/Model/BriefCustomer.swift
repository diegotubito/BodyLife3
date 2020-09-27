//
//  CustomerModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 12/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Foundation

struct FullCustomer: Decodable {
    var briefInfo : BriefCustomer
}


class CustomerModel {
    struct Old: Decodable {
        var apellido : String
        var nombre: String
        var localidad: String
        var telefono: String
        var obraSocial:String?
        var fechaRuta:String
        var genero:String
        var fechaNacimiento: String
        var fechaIngreso:String
        var dni:String
        var direccion:String
        var correo:String
        var childIDUsuario: String?
        var childID: String
    }
    struct Full : Encodable {
        var uid : String
        var timestamp : Double
        var dni : String
        var lastName : String
        var firstName : String
        var thumbnailImage : String?
        var street: String
        var locality: String
        var state: String
        var country: String
        var email : String
        var phoneNumber : String
        var user: String
        var longitude: Double
        var latitude: Double
    }
}
struct BriefCustomer: Decodable {
    var childID : String
    var createdAt : Double
    var dni : String
    var surname : String
    var name : String
    var thumbnailImage : String?
}


struct CustomerStatus: Decodable {
    var childID : String
    var surname : String
    var name : String
    var balance : Double
    var expiration : Double
    var childIDLastType : String
    var childIDLastActivity : String
    var childIDLastDiscount : String
}

class SellModel {
    struct Old : Decodable {
        var childID : String
        var precio : Double
        var childIDSocio : String
        var fechaCreacion : String
        var esAnulado : Bool
        var fechaInicial : String
        var fechaVencimiento : String
    }
    
    struct Register: Encodable, Decodable {
        var childID : String
        var childIDCustomer : String
        var childIDDiscount : String?
        var childIDActivity : String?
        var childIDArticle : String?
        var childIDPeriod : String?
        var createdAt : Double
        var amountDiscounted : Double
        var fromDate : Double?
        var toDate : Double?
        var amount : Double
        var price : Double
        var displayName : String
        var isEnabled : Bool
        var payments : [Payment]?
        var operationCategory : String
        var queryByDMY : String
        var queryByMY : String
        var queryByY : String
        
        var balance : Double?
        var totalPayment : Double?
    }
}

struct Payment: Encodable, Decodable {
    var childID : String
    var childIDCustomer : String
    var childIDSell : String
    var amount : Double
}
