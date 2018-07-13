import React from 'react'
import { Tab } from 'semantic-ui-react';
import { Input } from 'semantic-ui-react';
import { Button } from 'semantic-ui-react';
import { Grid,Card } from 'semantic-ui-react';

const items = [
    {
      header: 'Number of Coins - Black',
      description: 'Leverage agile frameworks to provide a robust synopsis for high level overviews.',
      meta: 'ROI: 1',
    },
    {
      header: 'Number of Coins - White',
      description: 'Bring to the table win-win survival strategies to ensure proactive domination.',
      meta: 'ROI: 100',
    },
  ]


const panes = [
  { menuItem: 'Mark Black', render: () => (
        <Tab.Pane>
        <Grid columns='equal'>
            <Grid.Row>
            <Grid.Column>
            <Input fluid placeholder='Transcation Id' />
            </Grid.Column>
            <Grid.Column>
            <Button primary>Spotted</Button>
            </Grid.Column>
            </Grid.Row>
        </Grid>
        </Tab.Pane>) },
  { menuItem: 'Marketplace', render: () =>
    (   <Tab.Pane>
        <Grid columns='equal'>
        <Grid.Row stretched>
          <Grid.Column>
          <Input placeholder='Address...' />
          <hr/>
          <Input placeholder='Value...' />
          </Grid.Column>
          <Grid.Column width={4}>
          <Button primary>Trade</Button>
          </Grid.Column>
        </Grid.Row>
      </Grid>
        </Tab.Pane>)
    },
  { menuItem: 'My Account', render: () => (
    <Tab.Pane>
        <Card.Group centered items={items} />
    </Tab.Pane>) },
]



const TabExampleVerticalTabular = () => (
  <Tab menu={{ color:"blue",fluid: true, vertical: true, tabular: true }} panes={panes} />
)

export default TabExampleVerticalTabular