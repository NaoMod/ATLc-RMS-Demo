package fr.imt.atlc.example.bolt.transfo

import fr.eseo.atol.gen.ATOLGen
import fr.eseo.atol.gen.ATOLGen.Metamodel
import fr.eseo.atol.javafx.JFX

@ATOLGen(transformation="src/main/resources/productline2JFX.atl", metamodels=#[
    @Metamodel(name="PRODUCTLINE", impl=Productline),
	@Metamodel(name="JFX", impl=JFX)
])
class Productline2JFX {}
