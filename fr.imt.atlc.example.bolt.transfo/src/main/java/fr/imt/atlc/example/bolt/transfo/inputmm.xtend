package fr.imt.atlc.example.bolt.transfo

import fr.eseo.aof.xtend.utils.AOFAccessors
import fr.imt.atlc.example.bolt.product.ProductPackage
import fr.imt.atlc.example.bolt.product.Task
import fr.imt.atlc.example.bolt.factory.Stage
import fr.imt.atlc.example.bolt.factory.FactoryPackage

import static fr.eseo.atol.gen.MetamodelUtils.*

@AOFAccessors(ProductPackage, FactoryPackage)
class InputMM {
	public val __taskId = <Task, Integer>oneDefault(0)[
		_taskId
	]

	public val __machineCountMax = <Stage, Integer>oneDefault(0)[
		_machineCountMax
	]
}