import React from 'react'
import { Tab } from 'semantic-ui-react';
import { Input } from 'semantic-ui-react';
import { Button } from 'semantic-ui-react';
import { Grid,Card } from 'semantic-ui-react';
import web3 from '../ethereum/web3';
import web3ws from '../ethereum/web3ws';
// import axios from 'axios';
// import request from "superagent";
import { Header, Icon, Modal,Dropdown } from 'semantic-ui-react';
import NotGivingEthT from '../ethereum/NotGivingEthT';
// import { Button, Icon, Modal } from 'semantic-ui-react';

class TabExampleVerticalTabular extends React.Component {

  state = {
    addr:'',
    val:'',
    open: false,
    msg:'',
    tAddr:'',
    tVal:'',
    bAdrr:'',
    blcCount:'',
    whiteCount:'',
    victimSelected:'',
    victims:[],
    inlineStyle : {
      modal : {
        marginTop: '1000px !important',
        marginLeft: 'auto',
        marginRight: 'auto'
      }
    }
  }

  async componentDidMount()
  {
    // let victims = await NotGivingEthT.methods.listOpenVictims().call();
    // console.log(victims);
    // this.setState({victims:victims  });
  }
  modalClose = () =>{
    this.setState({ open: false });
  }

  approve = async () =>{
    const vs = this.state.victimSelected;
    await NotGivingEthT.methods.approve().send({
      from: {vs}
    });

  }

  handleClick = async () => {
    // const addr = this.state.addr;
    // const res = await request
    // .post('http://159.65.157.34:3001/spot')
    // .set('Content-Type', 'application/json')
    // .send({ tx: {addr}});
    // this.setState({ open: true });
    // console.log(res);
    // var result = JSON.parse(res.text);
    // console.log(result);
    // var msg = result['blackcointto']+' has been awarded '+web3.utils.fromWei(result['bwvalue'], 'ether')+' black coins'+'\n';
    // var msg1 = result['whitecointto']+' has been awarded '+web3.utils.fromWei(result['bwvalue'], 'ether')+' white coins';
    // console.log(msg);
    // this.setState({ msg: msg+msg1 });
    // console.log(addr);
    // console.log(result);

    console.log("HandleClick add" , this.state.addr)
    console.log("HandleClick val" , this.state.val)

     await NotGivingEthT.methods
      .transferWhiteCoin(this.state.addr,this.state.val)
      .call();
  }

  tradeClick = async () =>{
    console.log("tradeClick add" , this.state.tAddr)
    console.log("tradeClick val" , this.state.tVal)

     await NotGivingEthT.methods
      .transferWhiteCoin(this.state.tAddr,this.state.tVal)
      .call();
  };

  checkBalanceClick = async () => {

    var addr  = await web3.utils.toChecksumAddress(this.state.bAdrr);
    console.log("addr",addr)

    let black = await NotGivingEthT.methods.balanceOf(addr).call();
    console.log("black"+black)

    let white = await NotGivingEthT.methods.balanceOfWhite(addr).call();
    this.setState({ blcCount:black,whiteCount:white });
  };

  render() {
    const items = [
      {
        header:'Number of Coins - black',
        description: 'these coins make you untrusted',
        meta: this.props.black,
      },
      {
        header: 'Number of Coins - White',
        description: 'These coins make you super trusted',
        meta: this.props.white,
      }
    ];

    const balanceItems = [
      {
        header:'Number of Coins - black',
        description: 'these coins make you untrusted',
        meta: this.state.blcCount,
      },
      {
        header: 'Number of Coins - White',
        description: 'These coins make you super trusted',
        meta: this.state.whiteCount,
      }
    ];

    const panes = [
    { menuItem: 'Mark Black', render: () =>
            (   <Tab.Pane>
                <Grid columns='equal'>
                <Grid.Row stretched>
                  <Grid.Column>
                  <Input onChange={event =>
                    this.setState({ addr: event.target.value })}
                    placeholder='Address...' />
                  <hr/>
                  <Input onChange={event =>
                    this.setState({ val: event.target.value })}
                    placeholder='Value...' />
                  </Grid.Column>
                  <Grid.Column width={4}>
                  <Button onClick={this.handleClick} primary>Spotted</Button>
                  </Grid.Column>
                </Grid.Row>
                <Grid.Row>
                  <Grid.Column>
                    <Dropdown placeholder='Transcation' selection options={this.state.victims} />
                  </Grid.Column>
                  <Grid.Column>
                    <Button onClick={this.approve} primary>Approve</Button>
                  </Grid.Column>
                </Grid.Row>
              </Grid>
                </Tab.Pane>)
    },
      { menuItem: 'Marketplace', render: () =>
        (   <Tab.Pane>
            <Grid columns='equal'>
            <Grid.Row stretched>
              <Grid.Column>
              <Input onChange={event =>
                this.setState({ tAddr: event.target.value })}
                placeholder='Address...' />
              <hr/>
              <Input onChange={event =>
                this.setState({ tVal: event.target.value })}
                placeholder='Value...' />
              </Grid.Column>
              <Grid.Column width={4}>
              <Button onClick={this.tradeClick} primary>Trade</Button>
              </Grid.Column>
            </Grid.Row>
          </Grid>
            </Tab.Pane>)
        },
      { menuItem: 'My Account', render: () => (
        <Tab.Pane>
            <Card.Group centered items={items} />
        </Tab.Pane>) },
      { menuItem: 'Check Balances', render: () => (
        <Tab.Pane>
        <Grid columns='equal'>
        <Grid.Row stretched>
          <Grid.Column>
          <Input ref="addr" onChange={event =>
            this.setState({ bAdrr: event.target.value })}
            placeholder='Address...' />
          <hr/>
          </Grid.Column>
          <Grid.Column width={4}>
          <Button onClick={this.checkBalanceClick} primary>Check Balance</Button>
          </Grid.Column>
        </Grid.Row>
        <Grid.Row stretched>
          <Card.Group centered items={balanceItems} />
        </Grid.Row>
      </Grid>
        </Tab.Pane>) }
    ];


    return(
      <div>
        <Tab menu={{ color:"blue",fluid: true, vertical: true, tabular: true }}
        panes={panes} />
        <Modal style={this.state.inlineStyle.modal} open={this.state.open} closeIcon onClose={this.modalClose}>
        <Header icon='archive'/>
        <Modal.Content>
          <p>
            {this.state.msg}
          </p>
        </Modal.Content>
        <Modal.Actions>
          <Button color='green' onClick={this.modalClose} >
            OK
          </Button>
        </Modal.Actions>
      </Modal>
    </div>
    );
  }
}

export default TabExampleVerticalTabular;