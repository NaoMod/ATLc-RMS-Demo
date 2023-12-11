package fr.imt.atlc.example.bolt.transfo

import fr.eseo.atol.gen.ATOLGen
import fr.eseo.atol.gen.ATOLGen.Metamodel
import fr.eseo.atol.gen.plugin.constraints.common.Constraints

@ATOLGen(transformation="src/main/resources/factoryandproduct2productline.atl", metamodels=#[
	// @Metamodel(name="PRODUCT", impl=Product),
    // @Metamodel(name="FACTORY", impl=Factory),
    @Metamodel(name="PRODUCTFACTORY", impl=InputMM),
    @Metamodel(name="PRODUCTLINE", impl=Productline),
	@Metamodel(name="Constraints", impl=Constraints)
], extensions = #[Constraints])
class Factoryandproduct2Productline {}