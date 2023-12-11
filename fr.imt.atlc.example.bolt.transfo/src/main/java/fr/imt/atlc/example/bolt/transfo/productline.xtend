package fr.imt.atlc.example.bolt.transfo

import fr.eseo.aof.xtend.utils.AOFAccessors
import fr.imt.atlc.example.bolt.productline.ProductlinePackage
import fr.imt.atlc.example.bolt.productline.ConfiguredFactory
import fr.imt.atlc.example.bolt.productline.ConfiguredStage
import fr.imt.atlc.example.bolt.productline.Task

import static fr.eseo.atol.gen.MetamodelUtils.*

@AOFAccessors(ProductlinePackage)
class Productline {

	public val __targetProduction = <ConfiguredFactory, Integer>oneDefault(0)[
		_targetProduction
	]

	public val __taskId = <Task, Integer>oneDefault(0)[
		_taskId
	]
	
	public val __stageId = <ConfiguredStage, Integer>oneDefault(0)[
		_stageId
	]
	
	public val __machineCount = <ConfiguredStage, Integer>oneDefault(0)[
		_machineCount
	]
}