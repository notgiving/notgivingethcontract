import React from 'react';
import { Container } from 'semantic-ui-react';
import Head from 'next/head';
import Header from './Header';
// import imgabout from '../images/Face-Hacker.png';
// import img from '../images/Face-Hacker.png';
import { Image } from 'semantic-ui-react';

export default props => {
  return (
    <Container>
      <Head>
      <link rel="stylesheet"
      href="//cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.3.1/semantic.min.css"></link>
      </Head>
      <Header></Header>
      {props.children}
    </Container>
  );
};
