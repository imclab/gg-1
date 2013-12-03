#<< gg/core/bform

class gg.scale.train.Data extends gg.core.BForm
  @ggpackage = "gg.scale.train.Data"

  compute: (pairtable, params) ->
    gg.scale.train.Data.train pairtable, params, @log

  # these training methods assume that the tables's attribute names
  # have been mapped to the aesthetic attributes that the scales
  # expect
  @train: (pairtable, params, log) ->
    log ?= console.log

    partitions = pairtable.partition ['facet-x', 'facet-y', 'layer']
    for p in partitions
      table = p.left()
      md = p.right()
      md.each (row) ->
        console.log row.get('scales').toString()
        row.get('scales').train table, row.get('posMapping')

    pairtable = data.PairTable.union partitions
    pairtable = gg.scale.train.Master.train(pairtable, params)
    pairtable

