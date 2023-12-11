/****************************************************************
 *  Copyright (C) 2020 IMT 
 *
 *  This program and the accompanying materials are made
 *  available under the terms of the Eclipse Public License 2.0
 *  which is available at https://www.eclipse.org/legal/epl-2.0/
 *
 *  Contributors:
 *    - Matthew Coyle
 *    - Théo Le Calvar
 *
 *  version 1.0
 *
 *  SPDX-License-Identifier: EPL-2.0
 ****************************************************************/

package fr.imt.atlc.example.bolt.transfo

import com.google.common.collect.EvictingQueue
import fr.eseo.atlc.constraints.Constraint
import fr.eseo.atol.gen.plugin.constraints.common.EMFBoxable
import fr.eseo.atlc.constraints.Expression
import fr.eseo.atol.gen.AbstractRule
import fr.eseo.atol.gen.plugin.constraints.solvers.Constraints2Choco
import java.util.ArrayList
import java.util.Collections
import java.util.HashMap
import java.util.Queue
import javafx.application.Application
import javafx.scene.Group
import javafx.scene.Node
import javafx.scene.Scene
import javafx.scene.input.KeyEvent
import javafx.scene.input.MouseButton
import javafx.scene.input.MouseEvent
import javafx.scene.layout.Pane
import javafx.scene.shape.Circle
// import javafx.stage.Stage //not imported, and fully qualified because of MM
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl
import org.eclipse.papyrus.aof.core.AOFFactory
import org.eclipse.papyrus.aof.core.IBox

import fr.imt.atlc.example.bolt.product.Product
import fr.imt.atlc.example.bolt.product.ProductPackage
import fr.imt.atlc.example.bolt.product.ProductFactory
import fr.imt.atlc.example.bolt.product.Task
import fr.imt.atlc.example.bolt.product.TaskCharacteristic

import fr.imt.atlc.example.bolt.factory.Factory
import fr.imt.atlc.example.bolt.factory.FactoryPackage
import fr.imt.atlc.example.bolt.factory.FactoryFactory
import fr.imt.atlc.example.bolt.factory.Stage
import fr.imt.atlc.example.bolt.factory.StageCharacteristic

import fr.imt.atlc.example.bolt.productline.ProductlinePackage

import static extension fr.eseo.atol.javafx.JFXUtils.*

class App extends Application {
	// val IBox<Group> igroups
	val Group groups
    
    // 
    // Source Fields
    // 
    val Product product
    val Factory factory
    val Resource resource

	val Constraints2Choco cstr2choco
	val Factoryandproduct2Productline transfo
	val Productline2JFX viz





    // 
    //Constructor
    // 
	new() {
		transfo = new Factoryandproduct2Productline
		viz = new Productline2JFX
		cstr2choco = new Constraints2Choco(#[new EMFBoxable(transfo.PRODUCTFACTORYMM), new EMFBoxable(transfo.PRODUCTLINEMM)])
		extension val productline = transfo.PRODUCTLINEMM
		// extension val jfxMM = viz.JFXMM

		// This section sets up the use of the EMF Resource system
		// which allows us to store our models in .xmi files
		val rs = new ResourceSetImpl

		rs.resourceFactoryRegistry.extensionToFactoryMap.put(
			"xmi",
			new XMIResourceFactoryImpl
		)
		rs.packageRegistry.put(
			ProductPackage.eNS_URI,
			ProductPackage.eINSTANCE
		)

		rs.packageRegistry.put(
			FactoryPackage.eNS_URI,
			FactoryPackage.eINSTANCE
		)

		rs.packageRegistry.put(
			ProductlinePackage.eNS_URI,
			ProductlinePackage.eINSTANCE
		)

		resource = rs.createResource(URI.createFileURI("data.xmi"))
		product = genSampleProduct()
		// product = predTestProduct()
		resource.contents.add(product) //we want product info in the xmi
		factory = genSampleFactory()
		// factory = predTestFactory()
		resource.contents.add(factory) //we want the factory info in the xmi


		val result = transfo.Main(product, factory) //This line performs the transformation, resulting in the skeleton of the target model, and the constraint model
		resource.contents.add(result.t) //we want the configured factory info in the xmi

		val tcstrs = transfo.PRODUCTFACTORYMM._tasks(product).collect[t | transfo.Task(t,factory).cstr].collect[e | e as Expression] //Here we get the resulting constraints
		val scstrs = transfo.PRODUCTFACTORYMM._stages(factory).collect[t | transfo.Stage(t).cstr].collect[e | e as Expression]
		val cstrs = tcstrs.concat(scstrs)

		cstr2choco.apply(cstrs) //and give them to the solver
		//TODO: check solve result to know if a solution was found
		cstr2choco.solve() //this line asks the solver to do it's thang
		cstr2choco.debug()

		
		val vizresult = viz.Main(result.t) //This line performs the transformation from the previous result to a visualisation
		this.groups = vizresult.t
		resource.save(Collections.EMPTY_MAP)
	}

	def genSampleFactory() {
        val out = FactoryFactory.eINSTANCE.createFactory()
		val char = FactoryFactory.eINSTANCE.createStageCharacteristic()
		out.characteristics.add(char)

		val s1 = createStage(null,out,1,3,6,char)
		val s2 = createStage(s1,out,2,3,6,char)
		val s3 = createStage(s2,out,3,3,6,char)
		val s4 = createStage(s3,out,4,3,6,char)
		return out
	}

	def predTestFactory(){
        val out = FactoryFactory.eINSTANCE.createFactory()
		val char1 = FactoryFactory.eINSTANCE.createStageCharacteristic()
		char1.charId = 1
		out.characteristics.add(char1)
		val char2 = FactoryFactory.eINSTANCE.createStageCharacteristic()
		char2.charId = 2
		out.characteristics.add(char2)

		val s1 = createStage(null,out,1,3,6,char1)
		val s2 = createStage(s1,out,2,3,6,char2)
		return out
	}

	def createStage(Stage prev, Factory f, int id, int count, int max, StageCharacteristic tc) {
		val s = FactoryFactory.eINSTANCE.createStage()
		s.stageId = id
		s.machineCount = count
		s.machineCountMax = max

		//s.prev = prev

		s.characteristics.add(tc)
		f.stages.add(s)
		return s
	}


	def genSampleProduct() {
        val out = ProductFactory.eINSTANCE.createProduct()

		val char = ProductFactory.eINSTANCE.createTaskCharacteristic()
		out.characteristics.add(char)
   
		val t3 = createTask(3,null,out,char,"Center drill & S'face secondary locator holes DF201, 202; Bore M24 holes FF200, 201") //task 0 in xmi
		val t6 = createTask(6,t3,out,char,"Drill Secondary locator holes DF 201, 202 and machine ID dimple") //task 1 in xmi
		val t8 = createTask(8,t6,out,char,"Ream secondary locator holes DF201, 202")
		val t9 = createTask(9,t8,out,char,"Rough mill cover rail, finish mill rear face")
			val t1 = createTask(1,t9,out,char,"Finish mill front face FF")
				val t2 = createTask(2,t1,out,char,"Drill M6 holes on front face FF208, 209")
					val t4 = createTask(4,t2,out,char,"Tap M6 holes on front face FF 208, 209")
			val t5 = createTask(5,t9,out,char,"Drill, chamfer, S'face chimney holes CF270, 271")
				val t7 = createTask(7,t5,out,char,"Tap chimney holes CF270, 271")
			val t10 = createTask(10,t9,out,char,"Pilot drill & S'face oil galleys RF201, 202")
				val t13 = createTask(13,t10,out,char,"Drill oil galleys RF201, 202")
					val t14 = createTask(14,t13,out,char,"Tap oil galleys RF210, 211")
			val t11 = createTask(11,t9,out,char,"Finish bore and chamfer core hole RF203")
			val t12 = createTask(12,t9,out,char,"Finish bore and chamfer thermostat hole FF210")
			val t15 = createTask(15,t9,out,char,"Probe combustion chamber pads")
				val t16 = createTask(16,t15,out,char, "Rough mill deck face")
					val t17 = createTask(17,t16,out,char,"Rough ream primary locators DF 201, 202")
						val t43 = createTask(43,t17,out,char,"Spotface spring seats CF300 thru 305, 310 thru 315, head bolts DF201 thru 208")
						val t42 = createTask(42,t17,out,char,"Spotface chain cover holes DF211, 212, 213, part ID boss #3")
						val t18 = createTask(18,t17,out,char,"Drill oil drain holes DF 220, 221, 222")
						val t31 = createTask(31,t17,out,char,"Rough and finish mill intake & exhaust faces")
							val t32 = createTask(32,t31,out,char,"Drill M6 intake holes IF201 thru 204, cover face holes CF200, 201, 220 thru 226, exhaust face EF227, 240, AIR holes EF225, 226, 228 & 229, & mach. ID dimple")
								val t37 = createTask(37,t32,out,char,"Tap intake holes IF201 thru 204, cover face holes CF200 thru 204, 220 thru 226, exhaust face EF227, 240, AIR")
								val t38 = createTask(38,t32,out,char,"Bore intake gasket locator hole IF208, ignition ground hole CF276")
							val t33 = createTask(33,t31,out,char,"Drill M8 exhaust holes EF 208, 209, 212 thru 215, AIR holes EF 233 & 234")
								val t35 = createTask(35,t33,out,char,"Tap exhaust holes EF208, 209, 212 thru 215")
							val t34 = createTask(34,t31,out,char,"Drill M10 exhaust flange holes EF220, 221")
								val t36 = createTask(36,t34,out,char,"Tap exhaust flange holes EF220, 221")
						val t19 = createTask(19,t17,out,char,"Drill oil supply hole DF230 and machine ID dimple")
						val t20 = createTask(20,t17,out,char,"Drill spark plug holes CF 280, 281, 282")
							val t39 = createTask(39,t20,out,char,"Rough bore & C'bore spark plug holes CF280, 281, 282")
								val t40 = createTask(40,t39,out,char,"Finish ream spark plug holes CF280,281,282")
									val t41 = createTask(41,t40,out,char,"Tap spark plug holes CF280, 281, 282")
						val t21 = createTask(21,t17,out,char,"Pilot drill cross oil gallery hole EF200")
							val t25 = createTask(25,t21,out,char,"Drill cross oil gallery hole EF 200")
								val t29 = createTask(29,t25,out,char,"Tap cross oil gallery hole EF200")
						val t22 = createTask(22,t17,out,char,"Drill front cover holes DF211, 212, 213")
						val t23 = createTask(23,t17,out,char,"Rough bore intake valve seats, guides & throats DF300 thru 305")
						val t24 = createTask(24,t17,out,char,"Rough bore exhaust valve seats, guides & throats DF300 thru 305")
							val t26 = createTask(26,t24,out,char,"Drill valve guide holes DF300 thru 305, and 310 thru 315")
								val t28 = createTask(28,t26,out,char,"Finish ream intake valve seats, guides & throats DF300 thru 305")
								val t30 = createTask(30,t26,out,char,"Finish ream exhaust valve seats, guides & throats DF300 thru 305")
						val t27 = createTask(27,t17,out,char,"Drill head bolt holes DF203 thru")

		return out
	}

	def predTestProduct(){
		val out = ProductFactory.eINSTANCE.createProduct()

		val char1 = ProductFactory.eINSTANCE.createTaskCharacteristic()
		char1.charId = 1
		out.characteristics.add(char1)
		val char2 = ProductFactory.eINSTANCE.createTaskCharacteristic()
		char2.charId = 2
		out.characteristics.add(char2)

		val t1 = createTask(0,null,out,char2,"first task needs char2")
		val t2 = createTask(1,t1,out,char1,"second task needs char1 and t0 to be completed")

		return out
	}

	// var taskId = 0	
	def createTask(int id, Task prev, Product p, TaskCharacteristic tc, String str) {
		val t = ProductFactory.eINSTANCE.createTask()
		t.taskId = id
		t.prev = prev
		t.description = str
		t.characteristics.add(tc)
		p.tasks.add(t)
		return t
	}













    // Util
	def save(EObject o) {
		if (o.eResource === null) {
			throw new UnsupportedOperationException('''Cannot save «o», missing resource''')
		}
		
		o.eResource.save(Collections.EMPTY_MAP)
	} 
	
    // 
    // Run Code
    // 
	override start(javafx.stage.Stage stage) throws Exception {
		// Setup GUI stuff
		val Pane root = new Pane
		val scene = new Scene(root, 800, 800);
		stage.setScene(scene);
		stage.setTitle("Factory");
		stage.show();

		scene.stylesheets.add("/style.css")

		//Quit app on escape keypress
		scene.addEventHandler(KeyEvent.KEY_PRESSED, [KeyEvent t |
			switch t.getCode {
				case ESCAPE: {
					stage.close
				}
				case SPACE: {}
				default: {}
			}
		]);
		root.children.add(this.groups)
		// root.children.toBox.bind(this.igroups as IBox<?> as IBox<Node>)
	}

    def static void main(String[] args) {
		launch(args)
	}
}