
from scrapy.item import Item, Field
from scrapy.loader.processors import MapCompose, TakeFirst

class CryptotrackItem(Item):
    default_output_processor = TakeFirst()

    Exact_name = Field()
    Short_name = Field()
    Market_cap = Field()
    Today_rate = Field()
    Today_rank = Field()
